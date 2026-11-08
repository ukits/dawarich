# frozen_string_literal: true

module Visits
  class Create
    attr_reader :user, :params, :errors, :visit

    def initialize(user, params, report_exceptions: true)
      @user = user
      @params = params.respond_to?(:with_indifferent_access) ? params.with_indifferent_access : params
      @report_exceptions = report_exceptions
      @visit = nil
      @errors = nil
      @duplicate = false
      @created_place = nil
    end

    def call
      return false unless timestamps_usable?
      return false unless coordinates_usable?

      result = ActiveRecord::Base.transaction do
        place = find_or_create_place
        return false unless place

        create_visit(place)
      end

      enqueue_name_fetching

      result
    rescue ActiveRecord::RecordNotUnique
      @duplicate = true
      @visit = existing_visit
      revive(@visit) if @visit && revivable?(@visit)
      @errors = 'Failed to create visit: duplicate visit' unless @visit

      @visit || false
    rescue ActiveRecord::RecordInvalid => e
      report_exception(e, "Failed to create visit: #{e.message}")

      @errors = "Failed to create visit: #{e.message}"

      false
    rescue StandardError => e
      report_exception(e, "Failed to create visit: #{e.message}")

      @errors = "Failed to create visit: #{e.message}"
      false
    end

    def duplicate?
      @duplicate
    end

    private

    def report_exception(error, message)
      return unless @report_exceptions

      ExceptionReporter.call(error, message)
    end

    def revivable?(visit)
      return false if suggested?

      visit.soft_deleted? || visit.declined?
    end

    def coordinates_usable?
      if latitude.nil? || longitude.nil?
        @errors = 'Failed to create visit: invalid coordinates'
        return false
      end

      unless latitude.between?(-90, 90) && longitude.between?(-180, 180)
        @errors = 'Failed to create visit: coordinates out of range'
        return false
      end

      true
    end

    def latitude
      return @latitude if defined?(@latitude)

      @latitude = parse_coordinate(params[:latitude])
    end

    def longitude
      return @longitude if defined?(@longitude)

      @longitude = parse_coordinate(params[:longitude])
    end

    def parse_coordinate(value)
      return nil if value.blank?

      Float(value)
    rescue ArgumentError, TypeError
      nil
    end

    def timestamps_usable?
      if started_at.nil? || ended_at.nil?
        @errors = 'Failed to create visit: invalid timestamps'
        return false
      end

      if ended_at <= started_at
        @errors = 'Failed to create visit: ended_at must be after started_at'
        return false
      end

      true
    end

    def started_at
      return @started_at if defined?(@started_at)

      @started_at = parse_time(params[:started_at])
    end

    def ended_at
      return @ended_at if defined?(@ended_at)

      @ended_at = parse_time(params[:ended_at])
    end

    def parse_time(value)
      Visits::TimeValue.parse(value)
    end

    def find_or_create_place
      return supplied_place if supplied_place

      existing_place = find_existing_place

      return existing_place if existing_place

      create_new_place
    end

    def existing_visit
      place = supplied_place || find_existing_place
      return nil unless place

      user.visits.find_by(place_id: place.id, started_at: started_at)
    end

    def supplied_place
      return @supplied_place if defined?(@supplied_place)

      @supplied_place = user.places.find_by(id: params[:place_id]) if params[:place_id].present?
    end

    # Reuse only a same-name Place within the radius PlaceFinder uses for
    # detected visits. A nameless or differently named nearby Place is a
    # different place, so a new one is created instead (F16).
    def find_existing_place
      normalized_name = params[:name].to_s.strip.downcase
      return nil if normalized_name.blank?

      user.places.not_archived
          .where('LOWER(BTRIM(places.name)) = ?', normalized_name)
          .where(
            'ST_DWithin(places.lonlat::geography, ' \
            'ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)',
            longitude, latitude, Visits::PlaceFinder::SIMILARITY_RADIUS
          )
          .order(:id)
          .first
    end

    def create_new_place
      @created_place = Place.create!(
        user: user,
        name: params[:name],
        latitude: latitude,
        longitude: longitude,
        lonlat: "POINT(#{longitude} #{latitude})",
        city: address[:city].presence,
        country: address[:country].presence,
        geodata: address_geodata,
        source: :manual,
        user_named: !suggested?,
        machine_named: suggested?
      )
    rescue ActiveRecord::RecordInvalid => e
      report_exception(e, "Failed to create place: #{e.message}")
      nil
    end

    # Suggested places need a name; manual places sent without an address need
    # one filled in. A user-given name is locked and survives the lookup.
    def enqueue_name_fetching
      return unless suggested? || !address_known?
      return if @created_place.nil?
      return unless Geocoding::Config.for(user).enabled?

      Places::NameFetchingJob.perform_later(@created_place.id)
    rescue StandardError => e
      ExceptionReporter.call(e, "Failed to enqueue place name fetching: #{e.message}")
    end

    def address
      @address ||= params[:address].respond_to?(:key?) ? params[:address] : {}
    end

    def address_known?
      address_geodata.fetch('properties', {}).slice('street', 'city').any?
    end

    # Stored in the Photon shape the rest of the app reads from places.geodata.
    def address_geodata
      properties = {
        'street' => address[:street],
        'housenumber' => address[:house_number],
        'postcode' => address[:postcode],
        'city' => address[:city],
        'country' => address[:country]
      }.compact_blank
      properties.empty? ? {} : { 'properties' => properties }
    end

    def suggested?
      params[:status].to_s == 'suggested'
    end

    def create_visit(place)
      duration_minutes = ((ended_at - started_at) / 60).to_i

      @visit = user.visits.create!(
        name: @created_place.nil? && params[:name] == place.name ? nil : params[:name].presence,
        place: place,
        location_label: place&.name,
        started_at: started_at,
        ended_at: ended_at,
        duration: duration_minutes,
        status: params[:status].presence || :confirmed
      )

      assign_points_to_visit(@visit)

      @visit
    end

    # Re-creating a visit over its tombstone (or an old decline) is an explicit
    # undo: claim the time range's points again along with the revive.
    def revive(visit)
      Visit.transaction do
        assign_points_to_visit(visit)
        visit.update!(deleted_at: nil, status: :confirmed)
      end
    end

    # A manual visit owns every point in its time range, like a detected one,
    # so tracks, the points list and the map can group by visit (F17). It takes
    # over points a machine-suggested visit holds; redetection rewrites those.
    def assign_points_to_visit(visit)
      user.points
          .where(timestamp: visit.started_at.to_i..visit.ended_at.to_i)
          .update_all(visit_id: visit.id)
    end
  end
end

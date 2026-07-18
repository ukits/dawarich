# frozen_string_literal: true

module Visits
  # Applies velocity, track, and stats side effects when visits are created or destroyed.
  class SideEffects
    def initialize(visit)
      @visit = visit
      @user = visit.user
    end

    def on_create
      points = points_in_time_range
      return if points.none?

      dates = calendar_dates_for(points)
      points.update_all(velocity: '0.0')

      rebuild_tracks_and_stats(dates)
    end

    def on_destroy
      points = points_in_time_range.to_a
      return if points.empty?

      dates = calendar_dates_for(points)
      restore_velocities(points)
      release_points_from_visit
      rebuild_tracks_and_stats(dates)
    end

    private

    attr_reader :visit, :user

    def points_in_time_range
      user.points.where(timestamp: visit.started_at.to_i..visit.ended_at.to_i)
    end

    def calendar_dates_for(points)
      timezone = user.safe_settings.timezone.presence || 'UTC'

      Time.use_zone(timezone) do
        timestamps = points.is_a?(ActiveRecord::Relation) ? points.pluck(:timestamp) : points.map(&:timestamp)
        timestamps.map { |ts| Time.zone.at(ts).to_date }.uniq
      end
    end

    def restore_velocities(points)
      points.each do |point|
        stored_speed = original_speed_for(point)
        next if stored_speed.nil?

        point.update_columns(velocity: stored_speed.to_s)
      end
    end

    # The original GPS speed lives under raw_data.properties.speed (that's the
    # value the importers copy into the velocity column). Fall back to a
    # top-level raw_data.velocity for legacy rows that stored it there.
    def original_speed_for(point)
      raw = point.raw_data
      return nil unless raw.is_a?(Hash)

      properties = raw['properties'] || raw[:properties]
      speed = properties.is_a?(Hash) ? (properties['speed'] || properties[:speed]) : nil
      speed = raw['velocity'] if speed.nil?

      speed
    end

    # Detach the visit's points before rebuilding tracks so the freed points are
    # eligible for track inclusion again. Runs while the visit still exists, so
    # this is deterministic regardless of the dependent: :nullify timing on
    # visit.destroy and of when the async track jobs pick up the work.
    def release_points_from_visit
      Point.where(visit_id: visit.id).update_all(visit_id: nil)
    end

    def rebuild_tracks_and_stats(dates)
      Tracks::BuildServer.new(user, dates).call
      Stats::RecalculateServer.new(user, dates).call
    end
  end
end

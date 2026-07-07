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
        stored_velocity = point.raw_data.is_a?(Hash) ? point.raw_data['velocity'] : nil
        next if stored_velocity.nil?

        point.update_columns(velocity: stored_velocity.to_s)
      end
    end

    def rebuild_tracks_and_stats(dates)
      Tracks::BuildServer.new(user, dates).call
      Stats::RecalculateServer.new(user, dates).call
    end
  end
end

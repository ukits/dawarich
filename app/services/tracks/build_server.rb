# frozen_string_literal: true

# Rebuilds tracks for specific calendar days in the user's timezone.
# Deletes overlapping tracks for each day, then enqueues parallel generation.
class Tracks::BuildServer
  def initialize(user, dates)
    @user = user
    @dates = Array(dates).map(&:to_date).uniq
  end

  def call
    return if dates.empty?

    with_user_timezone do
      dates.each { |date| rebuild_day(date) }
    end
  end

  private

  attr_reader :user, :dates

  def with_user_timezone(&block)
    timezone = user.safe_settings.timezone.presence || 'UTC'
    Time.use_zone(timezone, &block)
  rescue ArgumentError
    Time.use_zone(ENV.fetch('TIME_ZONE', 'UTC'), &block)
  end

  def rebuild_day(date)
    day_start = date.in_time_zone.beginning_of_day
    day_end = date.in_time_zone.end_of_day

    user.tracks.where(
      '(start_at, end_at) OVERLAPS (?, ?)',
      day_start,
      day_end
    ).destroy_all

    Tracks::ParallelGenerator.new(
      user,
      start_at: day_start,
      end_at: day_end,
      mode: :bulk
    ).call
  end
end

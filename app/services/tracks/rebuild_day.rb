# frozen_string_literal: true

# Enqueues a rebuild of the tracks on the calendar day of +time+ in the
# user's timezone. Visit create/delete uses this so the points that entered
# or left a visit are segmented again with the tracks on either side.
class Tracks::RebuildDay
  def self.enqueue(user, time)
    return if user.blank? || time.blank?

    timezone = user.safe_settings.timezone.presence || 'UTC'
    day = time.in_time_zone(timezone)

    Time.use_zone(timezone) do
      Tracks::ParallelGeneratorJob.perform_later(
        user.id,
        start_at: day.beginning_of_day,
        end_at: day.end_of_day,
        mode: :bulk
      )
    end
  end
end

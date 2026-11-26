# frozen_string_literal: true

# Enqueues a bulk rebuild of tracks between the active visits that flank
# +visit+. Manual create/confirm/delete uses this so points that entered or
# left a visit are segmented again with the journeys on either side, without
# wiping an entire calendar day when neighbors exist.
class Tracks::RebuildAroundVisit
  def self.enqueue(visit)
    new(visit).enqueue
  end

  def initialize(visit)
    @visit = visit
    @user = visit.user
  end

  def enqueue
    return if user.blank? || visit.started_at.blank? || visit.ended_at.blank?

    Tracks::ParallelGeneratorJob.perform_later(
      user.id,
      start_at: range_start,
      end_at: range_end,
      mode: :bulk
    )
  end

  private

  attr_reader :visit, :user

  # Previous active visit's start → next active visit's end. Falls back to the
  # visit's local calendar day when a neighbor is missing.
  def range_start
    previous_visit&.started_at || day_bounds.first
  end

  def range_end
    next_visit&.ended_at || day_bounds.last
  end

  def previous_visit
    @previous_visit ||= neighbors
                        .where(ended_at: ..visit.started_at)
                        .order(ended_at: :desc)
                        .first
  end

  def next_visit
    @next_visit ||= neighbors
                    .where(started_at: visit.ended_at..)
                    .order(started_at: :asc)
                    .first
  end

  def neighbors
    user.visits.active.where.not(id: visit.id)
  end

  def day_bounds
    @day_bounds ||= begin
      timezone = user.safe_settings.timezone.presence || 'UTC'
      day = visit.started_at.in_time_zone(timezone)
      Time.use_zone(timezone) { [day.beginning_of_day, day.end_of_day] }
    end
  end
end

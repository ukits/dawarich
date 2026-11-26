# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tracks::RebuildAroundVisit do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:timezone) { user.safe_settings.timezone.presence || 'UTC' }

  def local_time(iso8601)
    Time.use_zone(timezone) { Time.zone.parse(iso8601) }
  end

  describe '.enqueue' do
    it 'rebuilds the local calendar day when the visit has no active neighbors' do
      visit = create(:visit,
                     user: user,
                     started_at: local_time('2024-06-15 12:00'),
                     ended_at: local_time('2024-06-15 13:00'))

      expect(Tracks::ParallelGeneratorJob).to have_been_enqueued.with(
        user.id,
        hash_including(
          mode: :bulk,
          start_at: local_time('2024-06-15').beginning_of_day,
          end_at: local_time('2024-06-15').end_of_day
        )
      )
      # clear the create enqueue before asserting a second call path
      clear_enqueued_jobs

      described_class.enqueue(visit)

      expect(Tracks::ParallelGeneratorJob).to have_been_enqueued.with(
        user.id,
        hash_including(
          mode: :bulk,
          start_at: local_time('2024-06-15').beginning_of_day,
          end_at: local_time('2024-06-15').end_of_day
        )
      )
    end

    it 'rebuilds from the previous visit start through the next visit end' do
      previous = create(:visit,
                        user: user,
                        started_at: local_time('2024-06-15 08:00'),
                        ended_at: local_time('2024-06-15 09:00'))
      visit = create(:visit,
                     user: user,
                     started_at: local_time('2024-06-15 12:00'),
                     ended_at: local_time('2024-06-15 13:00'))
      following = create(:visit,
                         user: user,
                         started_at: local_time('2024-06-15 16:00'),
                         ended_at: local_time('2024-06-15 17:00'))
      clear_enqueued_jobs

      described_class.enqueue(visit)

      expect(Tracks::ParallelGeneratorJob).to have_been_enqueued.with(
        user.id,
        hash_including(
          mode: :bulk,
          start_at: previous.started_at,
          end_at: following.ended_at
        )
      )
    end

    it 'ignores tombstoned and declined neighbors when resolving the range' do
      create(:visit,
             user: user,
             started_at: local_time('2024-06-15 07:00'),
             ended_at: local_time('2024-06-15 07:30'),
             deleted_at: Time.current)
      create(:visit,
             user: user,
             started_at: local_time('2024-06-15 18:00'),
             ended_at: local_time('2024-06-15 19:00'),
             status: :declined)
      active_previous = create(:visit,
                               user: user,
                               started_at: local_time('2024-06-15 08:00'),
                               ended_at: local_time('2024-06-15 09:00'))
      visit = create(:visit,
                     user: user,
                     started_at: local_time('2024-06-15 12:00'),
                     ended_at: local_time('2024-06-15 13:00'))
      clear_enqueued_jobs

      described_class.enqueue(visit)

      expect(Tracks::ParallelGeneratorJob).to have_been_enqueued.with(
        user.id,
        hash_including(
          mode: :bulk,
          start_at: active_previous.started_at,
          end_at: local_time('2024-06-15').end_of_day
        )
      )
    end
  end
end

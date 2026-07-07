# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visits::SideEffects do
  let(:user) { create(:user) }
  let(:day) { Time.zone.parse('2025-06-15 00:00:00') }
  let!(:visit) do
    create(:visit,
           user: user,
           started_at: day + 10.hours,
           ended_at: day + 12.hours,
           duration: 120,
           area: nil)
  end

  describe '#on_create' do
    let!(:point) do
      create(:point,
             user: user,
             timestamp: (day + 11.hours).to_i,
             velocity: '12.5')
    end
    let!(:track) do
      create(:track,
             user: user,
             start_at: day + 9.hours,
             end_at: day + 13.hours)
    end

    it 'zeros velocity for points in the visit time range' do
      allow(Tracks::ParallelGenerator).to receive(:new).and_return(instance_double(Tracks::ParallelGenerator, call: true))
      allow(Stats::CalculateMonth).to receive(:new).and_return(instance_double(Stats::CalculateMonth, call: true))

      described_class.new(visit).on_create

      expect(point.reload.velocity).to eq('0.0')
    end

    it 'deletes tracks overlapping affected dates and enqueues rebuild' do
      generator = instance_double(Tracks::ParallelGenerator, call: true)
      allow(Tracks::ParallelGenerator).to receive(:new).and_return(generator)
      allow(Stats::CalculateMonth).to receive(:new).and_return(instance_double(Stats::CalculateMonth, call: true))

      expect { described_class.new(visit).on_create }
        .to change { Track.exists?(track.id) }.from(true).to(false)

      expect(Tracks::ParallelGenerator).to have_received(:new).with(
        user,
        hash_including(mode: :bulk)
      )
    end
  end

  describe '#on_destroy' do
    let!(:point) do
      create(:point,
             user: user,
             timestamp: (day + 11.hours).to_i,
             velocity: '0.0',
             raw_data: { 'velocity' => '8.25' })
    end

    it 'restores velocity from raw_data and rebuilds tracks and stats' do
      build_server = instance_double(Tracks::BuildServer, call: true)
      stats_server = instance_double(Stats::RecalculateServer, call: true)
      allow(Tracks::BuildServer).to receive(:new).with(user, [day.to_date]).and_return(build_server)
      allow(Stats::RecalculateServer).to receive(:new).with(user, [day.to_date]).and_return(stats_server)

      described_class.new(visit).on_destroy

      expect(point.reload.velocity).to eq('8.25')
      expect(build_server).to have_received(:call)
      expect(stats_server).to have_received(:call)
    end
  end
end

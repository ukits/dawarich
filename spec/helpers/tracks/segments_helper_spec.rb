# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tracks::SegmentsHelper, type: :helper do
  describe '#modes_for_mode' do
    let(:user) { create(:user, settings: { 'enabled_transportation_modes' => %w[walking driving] }) }

    before do
      # No signed-in helper user, so the method reads the passed user's own
      # settings — the branch that matters here is how options get built.
      allow(helper).to receive(:current_user).and_return(nil)
    end

    it 'offers every mode the user has enabled' do
      expect(helper.modes_for_mode('walking', user).map(&:last)).to eq(%w[walking driving])
    end

    it 'keeps a disabled current mode selectable so an override is never silently lost' do
      options = helper.modes_for_mode('cycling', user)

      expect(options.map(&:last)).to eq(%w[cycling walking driving])
      expect(options.first.first).to include(I18n.t('transportation_modes.cycling'))
    end

    it 'agrees with the segment-based helper it backs' do
      segment = build_stubbed(:track_segment, transportation_mode: 'cycling')

      expect(helper.modes_for_segment(segment, user)).to eq(helper.modes_for_mode('cycling', user))
    end
  end

  describe '#mode_icon_name' do
    it 'maps known modes to lucide icons that exist in the vendored set' do
      %w[walking running cycling driving bus train flying boat motorcycle stationary unknown].each do |mode|
        name = helper.mode_icon_name(mode)
        path = Rails.root.join("app/assets/svg/icons/lucide/outline/#{name}.svg")

        expect(path).to exist, "#{mode} -> #{name}.svg is not vendored"
      end
    end

    it 'falls back to a generic marker for an unrecognised mode' do
      expect(helper.mode_icon_name('teleporting')).to eq('route')
    end
  end

  describe '#segment_time_range' do
    let(:user) { create(:user) }

    before do
      allow(helper).to receive(:current_user_safe_settings).and_return(user.safe_settings)
    end

    it 'formats start_at and end_at as HH:MM - HH:MM' do
      start_at = Time.zone.parse('2026-07-05 10:00:00')
      segment = build_stubbed(:track_segment, start_at: start_at, end_at: start_at + 10.minutes)

      expect(helper.segment_time_range(segment)).to eq('10:00 - 10:10')
    end

    it 'formats times in the viewer timezone' do
      user.settings['timezone'] = 'Asia/Seoul'
      allow(helper).to receive(:current_user_safe_settings).and_return(user.safe_settings)

      start_at = Time.utc(2026, 7, 5, 1, 0, 0)
      segment = build_stubbed(:track_segment, start_at: start_at, end_at: start_at + 10.minutes)

      expect(helper.segment_time_range(segment)).to eq('10:00 - 10:10')
    end

    it 'falls back to ordered point timestamps when the segment is index-anchored' do
      track = create(:track, user: user)
      base = Time.zone.parse('2026-07-05 10:00:00')
      11.times do |i|
        create(:point, user: user, track: track, timestamp: base.to_i + (i * 60))
      end
      segment = create(:track_segment, track: track, start_index: 0, end_index: 10)

      expect(helper.segment_time_range(segment)).to eq('10:00 - 10:10')
    end

    it 'returns nil when neither times nor indexes resolve' do
      track = build_stubbed(:track)
      allow(track).to receive(:ordered_point_timestamps).and_return([])
      segment = build_stubbed(:track_segment, start_at: nil, end_at: nil,
                                              start_index: 0, end_index: 10, track: track)

      expect(helper.segment_time_range(segment)).to be_nil
    end
  end
end

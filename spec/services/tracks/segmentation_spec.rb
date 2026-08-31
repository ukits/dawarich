# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tracks::Segmentation do
  let(:segmenter_class) do
    Class.new do
      include Tracks::Segmentation

      def initialize(time_threshold_minutes: 30)
        @threshold = time_threshold_minutes
      end

      private

      attr_reader :threshold

      def time_threshold_minutes
        @threshold
      end
    end
  end

  let(:segmenter) { segmenter_class.new(time_threshold_minutes: 60) }

  describe '#split_points_into_segments_geocoder' do
    let(:base_time) { Time.zone.now.to_i }

    it 'keeps large spatial jumps within the same segment when time gap is below the threshold' do
      points = [
        build(:point, timestamp: base_time, latitude: 0, longitude: 0, lonlat: 'POINT(0 0)'),
        build(:point, timestamp: base_time + 5.minutes.to_i, latitude: 80, longitude: 170, lonlat: 'POINT(170 80)')
      ]

      segments = segmenter.send(:split_points_into_segments_geocoder, points)

      expect(segments.length).to eq(1)
      expect(segments.first).to eq(points)
    end

    it 'splits segments only when the time gap exceeds the threshold' do
      points = [
        build(:point, timestamp: base_time, latitude: 0, longitude: 0, lonlat: 'POINT(0 0)'),
        build(:point, timestamp: base_time + 5.minutes.to_i, latitude: 0.1, longitude: 0.1, lonlat: 'POINT(0.1 0.1)'),
        build(:point, timestamp: base_time + 2.hours.to_i, latitude: 1, longitude: 1, lonlat: 'POINT(1 1)'),
        build(:point, timestamp: base_time + 2.hours.to_i + 10.minutes.to_i, latitude: 1.1, longitude: 1.1,
lonlat: 'POINT(1.1 1.1)')
      ]

      segments = segmenter.send(:split_points_into_segments_geocoder, points)

      expect(segments.length).to eq(2)
      expect(segments.first).to eq(points.first(2))
      expect(segments.last).to eq(points.last(2))
    end

    it 'excludes visit points and terminates the track before a visit, starting a new one after' do
      before_visit = [
        build(:point, timestamp: base_time, latitude: 0, longitude: 0, lonlat: 'POINT(0 0)'),
        build(:point, timestamp: base_time + 1.minute.to_i, latitude: 0.1, longitude: 0.1, lonlat: 'POINT(0.1 0.1)')
      ]
      visit_points = [
        build(:point, timestamp: base_time + 2.minutes.to_i, visit_id: 42, latitude: 0.2, longitude: 0.2,
                      lonlat: 'POINT(0.2 0.2)'),
        build(:point, timestamp: base_time + 3.minutes.to_i, visit_id: 42, latitude: 0.2, longitude: 0.2,
                      lonlat: 'POINT(0.2 0.2)')
      ]
      after_visit = [
        build(:point, timestamp: base_time + 4.minutes.to_i, latitude: 0.3, longitude: 0.3, lonlat: 'POINT(0.3 0.3)'),
        build(:point, timestamp: base_time + 5.minutes.to_i, latitude: 0.4, longitude: 0.4, lonlat: 'POINT(0.4 0.4)')
      ]
      points = before_visit + visit_points + after_visit

      segments = segmenter.send(:split_points_into_segments_geocoder, points)

      expect(segments.length).to eq(2)
      expect(segments.first).to eq(before_visit)
      expect(segments.last).to eq(after_visit)
      expect(segments.flatten).not_to include(*visit_points)
    end
  end
end

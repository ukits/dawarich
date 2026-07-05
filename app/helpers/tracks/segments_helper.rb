# frozen_string_literal: true

module Tracks::SegmentsHelper
  def modes_for_segment(segment, user)
    settings = (current_user == user && current_user_safe_settings) || user.safe_settings
    enabled = settings.enabled_transportation_modes
    current_mode = segment.transportation_mode.to_s

    options = enabled.map { |m| [m.titleize, m] }
    return options if enabled.include?(current_mode)

    options.unshift(["#{current_mode.titleize} (disabled in settings)", current_mode])
  end

  def mode_emoji(mode)
    {
      'unknown' => '❓', 'stationary' => '🛑', 'walking' => '🚶',
      'running' => '🏃', 'cycling' => '🚴', 'driving' => '🚗',
      'bus' => '🚌', 'train' => '🚆', 'flying' => '✈️',
      'boat' => '⛵', 'motorcycle' => "\u{1F3CD}️"
    }[mode.to_s] || '❓'
  end

  def segment_distance(segment)
    return '-' unless segment.distance

    distance_km = segment.distance / 1000.0
    case current_user_safe_settings&.distance_unit
    when 'mi'
      "#{(distance_km * 0.621371).round(2)} mi"
    else
      "#{distance_km.round(2)} km"
    end
  end

  def segment_duration(segment)
    return '-' unless segment.duration

    minutes = segment.duration / 60
    return "#{minutes}m" if minutes < 60

    h = minutes / 60
    m = minutes % 60
    return "#{h}h" if m.zero?

    "#{h}h #{m}m"
  end

  def segment_time_range(segment)
    timestamps = segment.track.ordered_point_timestamps
    return nil if timestamps.blank?

    start_ts = timestamps[segment.start_index]
    end_ts = timestamps[segment.end_index]
    return nil unless start_ts && end_ts

    start_label = Time.zone.at(start_ts).strftime('%H:%M')
    end_label = Time.zone.at(end_ts).strftime('%H:%M')
    "#{start_label} - #{end_label}"
  end
end

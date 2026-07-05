# frozen_string_literal: true

module PointsHelper
  def link_to_date(timestamp)
    datetime = Time.zone.at(timestamp)

    link_to map_path(start_at: datetime.beginning_of_day, end_at: datetime.end_of_day), \
            class: 'underline hover:no-underline' do
      datetime.strftime('%Y-%m-%d')
    end
  end
end

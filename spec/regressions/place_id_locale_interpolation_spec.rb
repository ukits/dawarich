# frozen_string_literal: true

require 'rails_helper'

# YAML treats an unquoted `#` as a comment, so `place_id: Place #%{id}`
# loads as "Place" and the timeline/visit card shows no id. Keep these
# strings quoted.
RSpec.describe 'Place ID locale interpolation' do
  {
    'map.timeline_feeds.visit_entry.place_id' => 'Place #12345',
    'javascript.visits.place_id' => 'Place #12345'
  }.each do |key, expected|
    it "keeps the id placeholder in #{key} after YAML load" do
      expect(I18n.t(key, id: 12_345, locale: :en)).to eq(expected)
    end
  end
end

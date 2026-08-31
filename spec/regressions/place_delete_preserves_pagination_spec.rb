# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Deleting a place preserves the current pagination page', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it 'redirects back to the page the place was deleted from' do
    places = create_list(:place, 21, user:)
    target = places.last

    delete place_url(target, page: 2)

    expect(response).to redirect_to(places_url(page: 2))
  end

  it 'preserves name and source filters when deleting a place' do
    place = create(:place, user:, name: 'Filter Target', source: :manual)

    delete place_url(place, name: 'Filter', source: 'manual', page: 1)

    expect(response).to redirect_to(places_url(name: 'Filter', source: 'manual', page: 1))
  end

  it 'renders delete links that carry the current page' do
    create_list(:place, 21, user:)

    get places_url(page: 2)

    delete_links = response.body.scan(%r{<a\b[^>]*>Delete</a>})
    expect(delete_links).not_to be_empty
    expect(delete_links).to all(include('page=2'))
  end
end

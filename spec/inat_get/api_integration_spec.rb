```ruby
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/inat-get/data/api'

RSpec.describe INatGet::API, :integration do
  around(:each) do |example|
    VCR.turned_off { example.run }
  end

  describe '.get' do
    it 'fetches a taxon by ID' do
      response = INatGet::API.get('taxa/5268', fields: 'id,name')
      expect(response).to be_a(Hash)
      expect(response['id']).to eq(5268)
      expect(response['name']).to eq('Lepidoptera')
    end

    it 'fetches a project by ID' do
      response = INatGet::API.get('projects/174653', fields: 'id,title')
      expect(response).to be_a(Hash)
      expect(response['id']).to eq(174653)
      expect(response).to have_key('title')
    end

    it 'fetches a user by ID' do
      response = INatGet::API.get('users/3531113', fields: 'id,login')
      expect(response).to be_a(Hash)
      expect(response['id']).to eq(3531113)
      expect(response).to have_key('login')
    end

    it 'fetches an observation by ID' do
      response = INatGet::API.get('observations/227676908', fields: 'id,taxon_id')
      expect(response).to be_a(Hash)
      expect(response['id']).to eq(227676908)
      expect(response).to have_key('taxon_id')
    end
  end

  describe '.query' do
    it 'fetches observations with pagination' do
      results = INatGet::API.query('observations', project_id: 174653, taxon_id: 5268, user_id: 3531113, per_page: 100)
      expect(results).to be_an(Array)
      expect(results.size).to be > 0
      expect(results.first).to be_a(Hash)
      expect(results.first).to have_key('id')
      expect(Thread.current[:common_cache]).not_to be_nil
    end

    it 'processes results with a block' do
      ids = []
      INatGet::API.query('observations', project_id: 174653, taxon_id: 5268, user_id: 3531113, per_page: 100) do |item|
        ids << item['id']
      end
      expect(ids).not_to be_empty
    end
  end
end
```
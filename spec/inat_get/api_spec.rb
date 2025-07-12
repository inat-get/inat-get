```ruby
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/inat-get/data/api'

RSpec.describe INatGet::API, :fast, :vcr do
  describe '.get' do
    it 'fetches a taxon by ID', :vcr do
      response = INatGet::API.get('taxa/5268', fields: 'id,name')
      expect(response).to be_a(Hash)
      expect(response['id']).to eq(5268)
      expect(response).to have_key('name')
    end

    it 'fetches a project by ID', :vcr do
      response = INatGet::API.get('projects/174653', fields: 'id,title')
      expect(response).to be_a(Hash)
      expect(response['id']).to eq(174653)
      expect(response).to have_key('title')
    end

    it 'fetches a user by ID', :vcr do
      response = INatGet::API.get('users/3531113', fields: 'id,login')
      expect(response).to be_a(Hash)
      expect(response['id']).to eq(3531113)
      expect(response).to have_key('login')
    end

    it 'fetches an observation by ID', :vcr do
      response = INatGet::API.get('observations/227676908', fields: 'id,taxon_id')
      expect(response).to be_a(Hash)
      expect(response['id']).to eq(227676908)
      expect(response).to have_key('taxon_id')
    end

    it 'handles 404 error', :vcr do
      expect { INatGet::API.get('observations/999999999') }.to raise_error(/API error: 404/)
    end

    it 'handles 400 error', :vcr do
      expect { INatGet::API.get('observations/invalid') }.to raise_error(/API error: 400/)
    end

    it 'handles 429 error', :vcr do
      expect { INatGet::API.get('observations/123', headers: { 'X-Rate-Limit' => '429' }) }.to raise_error(/Rate limit exceeded/)
    end
  end

  describe '.query' do
    it 'fetches observations with pagination', :vcr do
      results = INatGet::API.query('observations', project_id: 174653, taxon_id: 5268, user_id: 3531113, per_page: 100)
      expect(results).to be_an(Array)
      expect(results.size).to be > 0
      expect(results.first).to be_a(Hash)
      expect(results.first).to have_key('id')
    end

    it 'processes results with a block', :vcr do
      ids = []
      INatGet::API.query('observations', project_id: 174653, taxon_id: 5268, user_id: 3531113, per_page: 100) do |item|
        ids << item['id']
      end
      expect(ids).not_to be_empty
    end

    it 'handles empty results', :vcr do
      results = INatGet::API.query('observations', taxon_id: 999999999)
      expect(results).to eq([])
    end
  end

  describe 'rate limiting' do
    it 'prevents exceeding 100 requests per minute' do
      allow(Time).to receive(:now).and_return(Time.at(0), Time.at(1))
      100.times { INatGet::API.send(:with_rate_limit) { nil } }
      expect_any_instance_of(Mutex).to receive(:synchronize).and_call_original
      expect(Kernel).to receive(:sleep).with(59.0).once
      INatGet::API.send(:with_rate_limit) { nil }
    end

    it 'synchronizes in multiple threads' do
      allow(Time).to receive(:now).and_return(Time.at(0))
      threads = 10.times.map do
        Thread.new do
          10.times { INatGet::API.send(:with_rate_limit) { nil } }
        end
      end
      threads.each(&:join)
      expect(INatGet::API.instance_variable_get(:@request_timestamps).size).to eq(100)
    end
  end
end
```
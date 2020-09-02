require 'rails_helper'

# Requires you to set the url via a let statement
# e.g. let(:url) { "/my/api/endpoint" }
RSpec.shared_examples "an authenticated request" do |request_method|
  describe 'authentication' do
    let!(:thermostat) { create(:thermostat) }
    let!(:household_token) { thermostat.household_token }

    context 'missing household_token' do
      it 'returns 401' do
        send(request_method, url, headers: {})

        expect(response.status).to eq(401)
      end
    end

    context 'invalid household_token' do
      it 'returns 401' do
        send(request_method, url, headers: { 'X-Household-Token': 'NOT A VALID KEY'})

        expect(response.status).to eq(401)
      end
    end

    context 'household_token is present' do
      it 'returns not 401' do
        send(request_method, url, headers: { 'X-Household-Token': household_token })

        expect(response.status).to_not eq(401)
      end
    end
  end
end

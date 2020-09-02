require 'rails_helper'

RSpec.describe '/api/v1/thermostat_readings/statistics', type: :request do
  let!(:url) { '/api/v1/thermostat_readings/statistics' }
  let!(:thermostat) { create(:thermostat) }
  let!(:auth_headers) do
    {
      'X-Household-Token': thermostat.household_token
    }
  end

  describe 'GET /api/v1/thermostat_reading/statistics' do
    it_behaves_like 'an authenticated request', :get

    context 'no readings present' do
      it 'returns a 404' do
        assert thermostat.thermostat_readings.length.zero?

        get url,
            headers: auth_headers

        expect(response.status).to eq(404)
        expect(json['errors']).to be_present
        expect(json['errors']['not_found']).to eq('No statistics calculable')
      end
    end

    context 'readings present' do
      it 'returns the calculated statistics' do
        create(:thermostat_reading, temperature: 5.0,
                                    humidity: 15.0,
                                    battery_charge: 30.0,
                                    thermostat: thermostat)
        create(:thermostat_reading, temperature: 7.0,
                                    humidity: 17.0,
                                    battery_charge: 32.0,
                                    thermostat: thermostat)
        create(:thermostat_reading, temperature: 10.0,
                                    humidity: 20.0,
                                    battery_charge: 35.0,
                                    thermostat: thermostat)

        get url,
            headers: auth_headers

        expect(response.status).to eq(200)

        expect(json['min_temperature']).to eq(5.0)
        expect(json['max_temperature']).to eq(10)
        expect(json['avg_temperature']).to be_within(0.01).of(7.33)

        expect(json['min_humidity']).to eq(15.0)
        expect(json['max_humidity']).to eq(20.0)
        expect(json['avg_humidity']).to be_within(0.01).of(17.33)

        expect(json['min_battery_charge']).to eq(30.0)
        expect(json['max_battery_charge']).to eq(35.0)
        expect(json['avg_battery_charge']).to be_within(0.01).of(32.33)
      end
    end
  end
end

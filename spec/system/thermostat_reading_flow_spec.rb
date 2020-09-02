require 'rails_helper'
RSpec.describe 'Thermostat Reading Flow', type: :request do
  before(:each) do
    $REDIS_CONNECTION_POOL.with do |connection|
      connection.flushdb
    end
    ThermostatReadingWriteWorker.clear
  end

  describe 'store and retrieve feature' do
    let!(:thermostat) { create(:thermostat) }
    let!(:household_token) { thermostat.household_token }
    let!(:auth_headers) { { 'X-Household-Token': household_token } }

    it 'stores a new reading and one can retrieve it' do
      payload = attributes_for(:thermostat_reading).slice(:temperature,
                                                          :humidity,
                                                          :battery_charge)

      post '/api/v1/thermostat_readings', params: payload, headers: auth_headers

      expect(response.status).to eq(201)

      thermostat_reading_id = json['sequence_number']

      get "/api/v1/thermostat_readings/#{thermostat_reading_id}", headers: auth_headers

      expect(response.status).to eq(200)

      expect(json['temperature']).to eq(payload[:temperature])
      expect(json['humidity']).to eq(payload[:humidity])
      expect(json['battery_charge']).to eq(payload[:battery_charge])

      expect(ThermostatReadingWriteWorker.jobs.count).to eq(1)
    end
  end

  describe 'store and retrieve statistics feature' do
    def post_thermostat_reading(auth_headers, temperature, humidity, battery_charge)
      payload = {
        temperature: temperature,
        humidity: humidity,
        battery_charge: battery_charge
      }
      post '/api/v1/thermostat_readings', params: payload, headers: auth_headers
      expect(response.status).to eq(201)
    end

    let!(:thermostat) { create(:thermostat) }
    let!(:household_token) { thermostat.household_token }
    let!(:auth_headers) { { 'X-Household-Token': household_token } }

    it 'stores a new reading and one can retrieve it' do
      post_thermostat_reading(auth_headers, 30, 40, 50)
      post_thermostat_reading(auth_headers, 32, 42, 52)
      post_thermostat_reading(auth_headers, 35, 45, 55)

      get "/api/v1/thermostat_readings/statistics", headers: auth_headers

      expect(response.status).to eq(200)

      expect(json['min_temperature']).to eq(30.0)
      expect(json['max_temperature']).to eq(35.0)
      expect(json['avg_temperature']).to be_within(0.1).of(32.3)

      expect(json['min_humidity']).to eq(40.0)
      expect(json['max_humidity']).to eq(45.0)
      expect(json['avg_humidity']).to be_within(0.1).of(42.3)

      expect(json['min_battery_charge']).to eq(50.0)
      expect(json['max_battery_charge']).to eq(55.0)
      expect(json['avg_battery_charge']).to be_within(0.1).of(52.3)
    end
  end
end

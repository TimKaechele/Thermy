require 'rails_helper'

RSpec.describe '/api/v1/thermostat_readings', type: :request do
  describe 'POST /api/v1/thermostat_readings' do
    let!(:url) { '/api/v1/thermostat_readings' }
    let!(:thermostat) { create(:thermostat) }
    let!(:auth_headers) do
      {
        'X-Household-Token': thermostat.household_token
      }
    end

    context 'valid parameters' do
      let!(:payload) {
        attributes_for(:thermostat_reading).slice(:temperature,
                                                  :humidity,
                                                  :battery_charge)
      }
      it 'saves the record with the given attributes' do
        expect do
          post url, params: payload, headers: auth_headers
        end.to change { ThermostatReading.count }.by(1)

        latest_entry = ThermostatReading.order(created_at: :desc).first

        expect(latest_entry.temperature).to eq(payload[:temperature])
        expect(latest_entry.humidity).to eq(payload[:humidity])
        expect(latest_entry.battery_charge).to eq(payload[:battery_charge])
      end

      it 'returns a sequence number in the payload' do
        post url, params: payload, headers: auth_headers

        expect(json['sequence_number']).to be_present
      end

      it 'returns a 201 status and the reading payload' do
        post url, params: payload, headers: auth_headers

        expect(response.status).to eq(201)

        expect(json['sequence_number']).to be_present
        expect(json['temperature']).to eq(payload[:temperature])
        expect(json['humidity']).to eq(payload[:humidity])
        expect(json['battery_charge']).to eq(payload[:battery_charge])
      end
    end

    context 'invalid parameters' do
      it 'returns an error payload' do
        post url, params: {
          humidity: -40.0,
          temperature: nil,
          battery_charge: 30.0
        }, headers: auth_headers

        expect(response.status).to eq(400)
        expect(json['errors']).to be_present
        expect(json['errors'].keys).to match_array(["humidity", "temperature"])
      end
    end
  end
end

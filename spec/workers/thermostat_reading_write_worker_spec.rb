require 'rails_helper'
RSpec.describe ThermostatReadingWriteWorker, type: :worker do
  context 'existent key' do
    let!(:key) { "test:reading:#{SecureRandom.uuid}" }
    let!(:thermostat) { create(:thermostat) }
    let!(:thermostat_reading) { build(:thermostat_reading, thermostat: thermostat) }
    before(:each) do
      $REDIS_CONNECTION_POOL.with do |connection|
        connection.flushdb
        connection.set(key, thermostat_reading.to_json)
      end
    end

    it 'persists the record' do
      expect do
        ThermostatReadingWriteWorker.new.perform(key)
      end.to(change { ThermostatReading.count }.by(1))

      latest_thermostat_reading = ThermostatReading.order(created_at: :desc).first

      expect(latest_thermostat_reading.sequence_number).to eq(thermostat_reading.sequence_number)
      expect(latest_thermostat_reading.temperature).to eq(thermostat_reading.temperature)
      expect(latest_thermostat_reading.humidity).to eq(thermostat_reading.humidity)
      expect(latest_thermostat_reading.battery_charge).to eq(thermostat_reading.battery_charge)
    end
  end

  context 'nonexistent key' do
    let!(:key) { "THIS_KEY_SHOULD_NOT_EXIST:#{SecureRandom.uuid}" }

    it 'raises a key not found error' do
      expect do
        ThermostatReadingWriteWorker.new.perform(key)
      end.to raise_error(ThermostatReadingWriteWorker::KeyNotFoundError)
    end

    it 'does not persist anything' do
      expect do
        begin
          ThermostatReadingWriteWorker.new.perform(key)
        rescue ThermostatReadingWriteWorker::KeyNotFoundError => e
        end
      end.to_not(change { ThermostatReading.count })
    end
  end
end

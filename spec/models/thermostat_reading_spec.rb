require 'rails_helper'

RSpec.describe ThermostatReading, type: :model do
  # @TODO(TIM): Add specs for model validatiosn

  describe '#stats_for_thermostat' do
    let!(:thermostat) { create(:thermostat) }
    context 'readings present' do
      it 'calculates the results correctly' do
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

        result = ThermostatReading.stats_for_thermostat(thermostat)

        expect(result['min_temperature']).to eq(5.0)
        expect(result['max_temperature']).to eq(10)
        expect(result['avg_temperature']).to be_within(0.01).of(7.33)

        expect(result['min_humidity']).to eq(15.0)
        expect(result['max_humidity']).to eq(20.0)
        expect(result['avg_humidity']).to be_within(0.01).of(17.33)

        expect(result['min_battery_charge']).to eq(30.0)
        expect(result['max_battery_charge']).to eq(35.0)
        expect(result['avg_battery_charge']).to be_within(0.01).of(32.33)
      end
    end

    context 'no readings present' do
      it 'returns nil' do
        assert !ThermostatReading.where(thermostat: thermostat).any?

        result = ThermostatReading.stats_for_thermostat(thermostat)

        expect(result).to eq(nil)
      end
    end
  end
end

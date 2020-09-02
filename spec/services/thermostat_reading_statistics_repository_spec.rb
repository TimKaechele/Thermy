require 'rails_helper'
RSpec.describe ThermostatReadingRepository do
  let!(:repository) { ThermostatReadingStatisticsRepository.new }
  before(:each) do
    $REDIS_CONNECTION_POOL.with do |connection|
      connection.flushdb
    end
  end

  describe '#add' do
    let!(:thermostat) { create(:thermostat) }
    it 'stores statistics in redis' do
      thermostat_reading = build(:thermostat_reading, thermostat: thermostat)
      expect do
        repository.add(thermostat_reading)
      end.to(change do
        $REDIS_CONNECTION_POOL.with do |connection|
          connection.keys.count
        end
      end)
    end
  end

  describe '#statistics_for_thermostat' do
    let!(:thermostat) { create(:thermostat) }

    context 'no data for thermostat' do
      it 'returns nil' do
        result = repository.statistics_for_thermostat(thermostat)

        expect(result).to eq(nil)
      end
    end

    context 'data for thermostat present' do
      it 'returns nil' do
        repository.add(build(:thermostat_reading,
                              temperature: 5.0,
                              humidity: 15.0,
                              battery_charge: 30.0,
                              thermostat: thermostat))
        repository.add(build(:thermostat_reading,
                             temperature: 7.0,
                             humidity: 17.0,
                             battery_charge: 32.0,
                             thermostat: thermostat))
        repository.add(build(:thermostat_reading,
                             temperature: 10.0,
                             humidity: 20.0,
                             battery_charge: 35.0,
                             thermostat: thermostat))
        result = repository.statistics_for_thermostat(thermostat)

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
  end

end

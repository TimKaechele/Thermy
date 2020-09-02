require 'rails_helper'
RSpec.describe ThermostatReadingRepository do
  let!(:repository) { ThermostatReadingRepository.new }
  before(:each) do
    $REDIS_CONNECTION_POOL.with do |connection|
      connection.flushdb
    end
  end

  describe '#save' do
    let!(:thermostat) { create(:thermostat) }
    context 'invalid thermostat reading' do
      let!(:invalid_thermostat_reading) do
        build(:thermostat_reading, humidity: nil,
                                   thermostat: thermostat)
      end

      it 'does not change the sequence_number' do
        expect do
          repository.save(invalid_thermostat_reading)
        end.to_not(change do
          $REDIS_CONNECTION_POOL.with do |connection|
            connection.get(repository.send(:sequence_key, thermostat.household_token))
          end
        end)
      end

      it 'returns false' do
        result = repository.save(invalid_thermostat_reading)
        expect(result).to eq(false)
      end

      it 'does not schedule any jobs' do
        expect do
          repository.save(invalid_thermostat_reading)
        end.to_not(change { ThermostatReadingWriteWorker.jobs.count })
      end

      it 'does not create any redis entries' do
        expect do
          repository.save(invalid_thermostat_reading)
        end.to_not(change do
          $REDIS_CONNECTION_POOL.with do |connection|
            connection.keys.count
          end
        end)
      end
    end

    context 'valid thermostat reading' do
      let(:thermostat_reading) do
        build(:thermostat_reading,
              thermostat: thermostat,
              sequence_number: nil)
      end

      it 'saves a redis key with the reading' do
        expect do
          repository.save(thermostat_reading)
        end.to(change do
          $REDIS_CONNECTION_POOL.with do |connection|
            connection.keys("reading:*:*").count
          end
        end.by(1))
      end

      it 'assigns a sequence number' do
        thermostat_reading_result = repository.save(thermostat_reading)

        expect(thermostat_reading_result.sequence_number).to be_present
      end

      it 'bumps up the sequence number' do
        expect do
          repository.save(thermostat_reading)
        end.to(change do
          $REDIS_CONNECTION_POOL.with do |connection|
            connection.get(repository.send(:sequence_key, thermostat.household_token)).to_i
          end
        end.by(1))
      end

      it 'schedules a thermostat write worker' do
        expect do
          repository.save(thermostat_reading)
        end.to(change { ThermostatReadingWriteWorker.jobs.count }.by(1))
      end
    end
  end

  describe '#find' do
    let!(:thermostat) { create(:thermostat) }
    let!(:household_token) { thermostat.household_token }

    context 'invalid houeshold key' do
      it 'returns nil' do
        result = repository.find(SecureRandom.uuid, -999)
        expect(result).to eq(nil)
      end
    end

    context 'nonexistent sequence number' do
      it 'returns nil' do
        result = repository.find(household_token, -999)
        expect(result).to eq(nil)
      end
    end

    context 'existent sequence number' do
      let(:thermostat_reading) { build(:thermostat_reading, thermostat: thermostat) }
      it "finds the reading by it's sequence number" do
        repository.save(thermostat_reading)

        result = repository.find(household_token, thermostat_reading.sequence_number)

        expect(result.temperature).to eq(thermostat_reading.temperature)
        expect(result.humidity).to eq(thermostat_reading.humidity)
        expect(result.battery_charge).to eq(thermostat_reading.battery_charge)
      end
    end
  end
end

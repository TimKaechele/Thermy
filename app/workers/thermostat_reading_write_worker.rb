class ThermostatReadingWriteWorker
  include Sidekiq::Worker
  class KeyNotFoundError < StandardError; end;

  def perform(key)
    ThermostatReading.create!(thermostat_reading_data(key))
  end

  private

  def thermostat_reading_data(key)
    thermostat_reading_json = nil
    $REDIS_CONNECTION_POOL.with do |connection|
      thermostat_reading_json = connection.get(key)
    end

    raise KeyNotFoundError, key if thermostat_reading_json.blank?

    JSON.parse(thermostat_reading_json)
  end
end

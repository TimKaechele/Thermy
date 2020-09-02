class ThermostatReadingRepository
  attr_reader :redis

  def initialize(redis: $REDIS_CONNECTION_POOL)
    @redis = redis
  end

  def save(thermostat_reading)
    # Set the sequence number to comply with the validation
    thermostat_reading.sequence_number = 0
    return false unless thermostat_reading.valid?

    household_token = thermostat_reading.thermostat.household_token

    redis.with do |connection|
      thermostat_reading.sequence_number = next_sequence_number(connection, household_token)
      key = save_reading_to_redis(connection, household_token, thermostat_reading)
      schedule_db_persistence_job(key)
    end

    thermostat_reading
  end

  def find(household_token, sequence_number)
    thermostat_reading_json = get_thermostat_reading_json(household_token, sequence_number)

    return nil if thermostat_reading_json.blank?

    build_thermostat_reading_from_json(thermostat_reading_json)
  end

  private

  def next_sequence_number(connection, household_token)
    connection.incr(sequence_key(household_token))
  end

  def save_reading_to_redis(connection, household_token, thermostat_reading)
    key = thermostat_reading_key(household_token, thermostat_reading.sequence_number)
    connection.set(key, thermostat_reading.to_json)
    key
  end

  def schedule_db_persistence_job(thermostat_reading_redis_key)
    ThermostatReadingWriteWorker.perform_async(thermostat_reading_redis_key)
  end

  def get_thermostat_reading_json(household_token, sequence_number)
    thermostat_reading_json = nil
    redis.with do |connection|
      key = thermostat_reading_key(household_token, sequence_number)
      thermostat_reading_json = connection.get(key)
    end
    thermostat_reading_json
  end

  def build_thermostat_reading_from_json(thermostat_reading_json)
    data = JSON.parse(thermostat_reading_json)
    ThermostatReading.new(data)
  end

  def sequence_key(household_token)
    "seq:#{household_token}"
  end

  def thermostat_reading_key(household_token, sequence_number)
    "reading:#{household_token}:#{sequence_number}"
  end
end

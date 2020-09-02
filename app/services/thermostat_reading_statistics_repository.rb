class ThermostatReadingStatisticsRepository
  attr_reader :redis
  CONSIDERED_ATTRIBUTES = [:temperature, :humidity, :battery_charge].freeze

  def initialize(redis: $REDIS_CONNECTION_POOL)
    @redis = redis
  end

  def add(thermostat_reading)
    thermostat = thermostat_reading.thermostat

    redis.with do |connection|
      CONSIDERED_ATTRIBUTES.each do |attribute|
        value = thermostat_reading[attribute.to_s]
        connection.multi do |multi|
          insert_value_for_average(multi, thermostat, attribute, value)
          insert_value_for_min_max(multi, thermostat, attribute, value)
        end
      end
    end
    true
  end

  def statistics_for_thermostat(thermostat)
    thermostat_reading_statistics = {}
    redis.with do |connection|
      CONSIDERED_ATTRIBUTES.each do |attribute|
        thermostat_reading_statistics[attribute] = statistics_for(connection, thermostat, attribute)
      end
    end
    statistics_result = flatten_statistics_hash(thermostat_reading_statistics)

    return nil if statistics_result.values.any?(&:blank?)

    statistics_result
  end
  private

  def statistics_for(connection, thermostat, attribute)
    {
      min: get_min(connection, thermostat, attribute)&.first&.to_f,
      max: get_max(connection, thermostat, attribute)&.first&.to_f,
      avg: calculate_average(get_avg(connection, thermostat, attribute))
    }
  end

  def get_min(connection, thermostat, attribute)
    connection.zrange(min_max_key(thermostat, attribute), 0, 0)
  end

  def get_max(connection, thermostat, attribute)
    connection.zrange(min_max_key(thermostat, attribute), -1, -1)
  end

  def get_avg(connection, thermostat, attribute)
    key = avg_key(thermostat, attribute)
    connection.hgetall(key)
  end

  def insert_value_for_min_max(multi, thermostat, attribute, value)
    key = min_max_key(thermostat, attribute)
    multi.zadd(key, value, value)
  end

  def insert_value_for_average(multi, thermostat, attribute, value)
    key = avg_key(thermostat, attribute)
    multi.hincrby(key, "count", 1)
    multi.hincrbyfloat(key, "sum", value)
  end

  def calculate_average(value_hash)
    return nil if value_hash['sum'].nil?
    return nil if value_hash['count'].nil? || value_hash['count'].to_i.zero?

    value_hash['sum'].to_f / value_hash['count'].to_i
  end

  def min_max_key(thermostat, attribute)
    "reading:statistics:#{thermostat.household_token}:#{attribute}:minmax"
  end

  def avg_key(thermostat, attribute)
    "reading:statistics:#{thermostat.household_token}:#{attribute}:avg"
  end

  def flatten_statistics_hash(nested_statistics_hash)
    Hash[nested_statistics_hash.flat_map do |measurement, aggregates|
      aggregates.map do |aggregate_function, aggregate_result|
        ["#{aggregate_function}_#{measurement}", aggregate_result]
      end
    end]
  end
end

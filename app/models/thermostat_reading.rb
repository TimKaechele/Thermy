class ThermostatReading < ApplicationRecord
  belongs_to :thermostat

  validates :sequence_number, presence: true
  validates :humidity, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }
  validates :battery_charge, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }
  validates :temperature, presence: true
  validates :temperature, numericality: true


  def self.stats_for_thermostat(thermostat)
    aggregate_sql_query = <<~SQL
      min(temperature) as min_temperature,
      max(temperature) as max_temperature,
      avg(temperature) as avg_temperature,

      min(humidity) as min_humidity,
      max(humidity) as max_humidity,
      avg(humidity) as avg_humidity,

      min(battery_charge) as min_battery_charge,
      max(battery_charge) as max_battery_charge,
      avg(battery_charge) as avg_battery_charge
    SQL
    self.where(thermostat: thermostat)
        .select(aggregate_sql_query)
        .group('thermostat_readings.thermostat_id')[0]
        &.attributes
        &.except('id')
  end
end

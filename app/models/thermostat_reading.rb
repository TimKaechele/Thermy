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
end

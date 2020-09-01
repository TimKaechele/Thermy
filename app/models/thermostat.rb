class Thermostat < ApplicationRecord
  has_many :thermostat_readings, dependent: :destroy

  validates :household_token, presence: true
  validates :household_token, uniqueness: true
  validates :street, presence: true
  validates :zip_code, presence: true
  validates :city, presence: true
  validates :country, presence: true
end

FactoryBot.define do
  factory :thermostat_reading do
    thermostat
    sequence(:sequence_number) { |i| i }
    temperature { rand(-30.0..60.00) }
    humidity { rand(0.0..100.0) }
    battery_charge { rand(0.0..100.0) }
  end
end

class ThermostatDemoDataSeeder
  def call
    unless Rails.env.development? || Rails.env.test?
      puts "Please run this seeder only in dev and test environments"
      return
    end
    thermostats = FactoryBot.create_list(:thermostat, 300)

    puts "Your household tokens:"
    puts thermostats.pluck(:household_token).join("\n")
  end
end

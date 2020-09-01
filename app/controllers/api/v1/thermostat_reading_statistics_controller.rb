module Api
  module V1
    class ThermostatReadingStatisticsController < ApplicationController
      def show
        thermostat_reading_statistics = ThermostatReading.stats_for_thermostat(current_thermostat)

        if thermostat_reading_statistics.present?
          render(json: thermostat_reading_statistics)
        else
          render(json: { errors: { not_found: 'No statistics calculable' } },
                 status: :not_found)
        end
      end
    end
  end
end

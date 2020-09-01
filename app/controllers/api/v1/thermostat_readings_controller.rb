module Api
  module V1
    class ThermostatReadingsController < ApplicationController
      def show
        thermostat_reading = ThermostatReading.where(thermostat: current_thermostat)
                                              .find_by!(sequence_number: params[:id])

        render(json: thermostat_reading)
      end

      def create
        thermostat_reading = ThermostatReading.new(thermostat_reading_params)
        thermostat_reading.thermostat_id = current_thermostat.id
        thermostat_reading.sequence_number = rand(100_000)
        if thermostat_reading.save
          render(json: thermostat_reading, status: :created)
        else
          render(json: { errors:  thermostat_reading.errors }, status: :bad_request)
        end
      end

      def thermostat_reading_params
        params.permit(:temperature, :humidity, :battery_charge)
      end
    end
  end
end

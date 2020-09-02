module Api
  module V1
    class ThermostatReadingsController < ApplicationController
      def show
        thermostat_reading = thermostat_reading_repository.find(current_thermostat.household_token, params[:id])

        return handle_not_found_error if thermostat_reading.blank?

        render(json: thermostat_reading_response(thermostat_reading))
      end

      def create
        thermostat_reading = ThermostatReading.new(thermostat_reading_params)
        thermostat_reading.thermostat_id = current_thermostat.id
        thermostat_reading.created_at = Time.zone.now

        if thermostat_reading_repository.save(thermostat_reading)
          thermostat_reading_statistics_repository.add(thermostat_reading)
          render(json: thermostat_reading_response(thermostat_reading), status: :created)
        else
          render(json: { errors:  thermostat_reading.errors }, status: :bad_request)
        end
      end

      private

      def thermostat_reading_params
        params.permit(:temperature, :humidity, :battery_charge)
      end

      def thermostat_reading_response(thermostat_reading)
        thermostat_reading.slice(:sequence_number, :temperature, :humidity, :battery_charge, :created_at)
      end

      def thermostat_reading_repository
        ThermostatReadingRepository.new
      end

      def thermostat_reading_statistics_repository
        ThermostatReadingStatisticsRepository.new
      end
    end
  end
end

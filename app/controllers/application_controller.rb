class ApplicationController < ActionController::API
  before_action :require_thermostat!
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found_error

  def require_thermostat!
    return render(json: { errors: {
                            authorization: 'Missing or invalid X-Household-Token' } },
                  status: :unauthorized) if current_thermostat.blank?

  end

  def current_thermostat
    @thermostat ||= Thermostat.select(:id, :household_token)
                              .find_by(household_token: request.headers['X-Household-Token'])
  end

  def handle_not_found_error
    return render(json: { errors: { not_found: "Error could not be found." } },
                  status: :not_found)
  end
end

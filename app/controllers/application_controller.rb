class ApplicationController < ActionController::API
  before_action :require_thermostat!

  def require_thermostat!
    return render(json: { errors: {
                            authorization: 'Missing or invalid X-Household-Token' } },
                  status: :unauthorized) if current_thermostat.blank?

  end

  def current_thermostat
    @thermostat ||= Thermostat.select(:id, :household_token)
                              .find_by(household_token: request.headers['X-Household-Token'])
  end
end

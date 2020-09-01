Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :thermostat_readings, only: [:show, :create]
    end
  end
end

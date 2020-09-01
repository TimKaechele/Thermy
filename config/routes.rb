Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :thermostat_readings, only: [:show, :create] do
        collection do
          get '/statistics', to: 'thermostat_reading_statistics#show'
        end
      end

    end
  end
end

module Controller
  module Api
    module PricingController

      def self.registered(app)

        require_relative '../../model/rental_location.rb'
        require_relative '../../model/rate_type.rb'
        require_relative '../../model/season_definition.rb'
        require_relative '../../model/season.rb'
        require_relative '../../service/pricing_service.rb'

        app.get '/api/rental-locations' do
          rental_locations = Service::PricingService.get_rental_locations
          rental_locations.to_json
        end

        app.get '/api/rate-types' do
          rental_location_id = params['rental-location-id'].to_i
          rate_types = Service::PricingService.get_rate_types(rental_location_id)
          rate_types.to_json
        end

        app.get '/api/season-definitions' do
          rental_location_id = params['rental-location-id'].to_i
          rate_type_id = params['rate-type-id'].to_i
          season_definitions = Service::PricingService.get_season_definitions(rental_location_id, rate_type_id)
          season_definitions.to_json
        end

        app.get '/api/seasons' do
          season_definition_id = params['season-definition-id'].to_i
          seasons = Service::PricingService.get_seasons(season_definition_id)
          seasons.to_json
        end

        app.get '/api/vehicles' do
          rental_location_id = params['rental-location-id'].to_i
          rate_type_id = params['rate-type-id'].to_i
          unit_id = params['unit-id'].to_i
          season_definition_id = params['season-definition-id']
          season_id = params['season-id']
          
          vehicles = Service::PricingService.get_vehicles(
            rental_location_id, 
            rate_type_id, 
            unit_id, 
            season_definition_id, 
            season_id
          )
          vehicles.to_json
        end

      end
    end
  end
end

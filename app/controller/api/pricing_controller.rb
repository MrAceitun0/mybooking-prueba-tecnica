module Controller
  module Api
    module PricingController

      def self.registered(app)

        require_relative '../../model/rental_location.rb'
        require_relative '../../model/rate_type.rb'
        require_relative '../../model/season_definition.rb'
        require_relative '../../model/season.rb'
        require_relative '../../service/pricing_service.rb'
        require_relative '../../utils/parameter_validator.rb'

        app.get '/api/rental-locations' do
          Service::PricingService.get_rental_locations.to_json
        end

        app.get '/api/rate-types' do
          Utils::ParameterValidator.validate_pricing_params(params, 'rental-location-id')
          Service::PricingService.get_rate_types(params['rental-location-id'].to_i).to_json
        end

        app.get '/api/season-definitions' do
          Utils::ParameterValidator.validate_pricing_params(params, 'rental-location-id', 'rate-type-id')
          Service::PricingService.get_season_definitions(
            params['rental-location-id'].to_i, 
            params['rate-type-id'].to_i
          ).to_json
        end

        app.get '/api/seasons' do
          Utils::ParameterValidator.validate_pricing_params(params, 'season-definition-id')
          Service::PricingService.get_seasons(params['season-definition-id'].to_i).to_json
        end

        app.get '/api/vehicles' do
          Utils::ParameterValidator.validate_pricing_params(params, 'rental-location-id', 'rate-type-id', 'unit-id')
          Service::PricingService.get_vehicles(
            params['rental-location-id'].to_i, 
            params['rate-type-id'].to_i, 
            params['unit-id'].to_i, 
            params['season-definition-id'], 
            params['season-id']
          ).to_json
        end

      end
    end
  end
end

module Controller
  module Api
    module PricingController

      def self.registered(app)

        require_relative '../../model/rental_location.rb'
        require_relative '../../model/rate_type.rb'
        require_relative '../../model/season_definition.rb'
        require_relative '../../model/season.rb'
        require_relative '../../utils/error_handler.rb'
        require_relative '../../utils/controller_utils.rb'

        app.get '/api/rental-locations' do
          Utils::ControllerUtils.safe_execute('cargar las sucursales') do
            rental_locations = ::Model::RentalLocation.all
            Utils::ControllerUtils.json_response(rental_locations)
          end
        end

        app.get '/api/rate-types' do
          Utils::ControllerUtils.safe_execute('cargar las tarifas') do
            Utils::ControllerUtils.validate_required_params(params, 'rental-location-id')
            Utils::ControllerUtils.validate_integer_params(params, 'rental-location-id')
            
            rental_location_id = params['rental-location-id'].to_i
            rate_type_ids = ::Model::CategoryRentalLocationRateType.all(rental_location_id: rental_location_id).map(&:rate_type_id).uniq
            
            Utils::ControllerUtils.handle_empty_results('rate types', "location '#{rental_location_id}'") if rate_type_ids.empty?
            
            rate_types = ::Model::RateType.all(:id => rate_type_ids)
            Utils::ControllerUtils.json_response(rate_types)
          end
        end

        app.get '/api/season-definitions' do
          Utils::ControllerUtils.safe_execute('cargar los grupos de temporada') do
            Utils::ControllerUtils.validate_required_params(params, 'rental-location-id', 'rate-type-id')
            Utils::ControllerUtils.validate_integer_params(params, 'rental-location-id', 'rate-type-id')
            
            rental_location_id = params['rental-location-id'].to_i
            rate_type_id = params['rate-type-id'].to_i
            
            price_definition_ids = ::Model::CategoryRentalLocationRateType
              .all(rental_location_id: rental_location_id)
              .all(rate_type_id: rate_type_id)
              .map(&:price_definition_id).uniq
            
            Utils::ErrorHandler.handle_empty_results('price definitions', "location '#{rental_location_id}' and rate type '#{rate_type_id}'") if price_definition_ids.empty?

            season_definition_ids = ::Model::PriceDefinition.all(:id => price_definition_ids).map(&:season_definition_id).compact.uniq
            Utils::ErrorHandler.handle_empty_results('season definitions', "location '#{rental_location_id}' and rate type '#{rate_type_id}'") if season_definition_ids.empty?
            
            season_definitions = ::Model::SeasonDefinition.all(:id => season_definition_ids)
            Utils::ControllerUtils.json_response(season_definitions)
          end
        end

        app.get '/api/seasons' do
          Utils::ControllerUtils.safe_execute('cargar las temporadas') do
            Utils::ControllerUtils.validate_required_params(params, 'season-definition-id')
            Utils::ControllerUtils.validate_integer_params(params, 'season-definition-id')
            
            season_definition_id = params['season-definition-id'].to_i
            seasons = ::Model::Season.all(season_definition_id: season_definition_id)
            
            Utils::ErrorHandler.handle_empty_results('seasons', "season definition '#{season_definition_id}'") if seasons.empty?

            Utils::ControllerUtils.json_response(seasons)
          end
        end

        app.get '/api/vehicles' do
          Utils::ControllerUtils.safe_execute('cargar los vehículos') do
            Utils::ControllerUtils.validate_required_params(params, 'rental-location-id', 'rate-type-id', 'unit-id')
            Utils::ControllerUtils.validate_integer_params(params, 'rental-location-id', 'rate-type-id', 'unit-id')
            
            rental_location_id = params['rental-location-id'].to_i
            rate_type_id = params['rate-type-id'].to_i
            season_definition_id = params['season-definition-id']
            season_id = params['season-id']
            unit_id = params['unit-id'].to_i

            unit_name = case unit_id
            when 1 then :months
            when 2 then :days
            when 3 then :hours
            when 4 then :minutes
            else :days
            end

            price_definition_ids = ::Model::CategoryRentalLocationRateType
              .all(rental_location_id: rental_location_id)
              .all(rate_type_id: rate_type_id)
              .map(&:price_definition_id).uniq

            Utils::ControllerUtils.handle_empty_results('price definitions', 'the given filters') if price_definition_ids.empty?

            if season_definition_id && season_definition_id != 'none'
              price_definitions = ::Model::PriceDefinition.all(:id => price_definition_ids, :season_definition_id => season_definition_id.to_i)
            else
              price_definitions = ::Model::PriceDefinition.all(:id => price_definition_ids)
            end

            Utils::ControllerUtils.handle_empty_results('price definitions', 'the given season definition') if price_definitions.empty?

            vehicles_data = []
            price_definitions.each do |price_def|
              category_rental_location_rate_type = ::Model::CategoryRentalLocationRateType.first(
                :price_definition_id => price_def.id,
                :rental_location_id => rental_location_id,
                :rate_type_id => rate_type_id
              )
              
              next unless category_rental_location_rate_type
              category = category_rental_location_rate_type.category
              next unless category

              prices = ::Model::Price.all(:price_definition_id => price_def.id)
              
              if season_id && season_id != ''
                prices = prices.select { |p| p.season_id == season_id.to_i }
              end
              
              if unit_id
                prices = prices.select { |p| p.time_measurement == unit_name }
              end

              next if prices.empty?

              vehicle_info = {
                id: category.id,
                name: category.name,
                prices: prices.map do |price|
                  {
                    id: price.id,
                    amount: price.units,
                    unit: price.time_measurement,
                    price: price.price
                  }
                end
              }

              vehicles_data << vehicle_info
            end

            Utils::ControllerUtils.handle_empty_results('vehicles', 'your conditions') if vehicles_data.empty?

            Utils::ControllerUtils.json_response(vehicles_data)
          end
        end

      end
    end
  end
end

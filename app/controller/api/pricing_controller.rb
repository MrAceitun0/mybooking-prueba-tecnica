module Controller
  module Api
    module PricingController

      def self.registered(app)

        require_relative '../../model/rental_location.rb'
        require_relative '../../model/rate_type.rb'
        require_relative '../../model/season_definition.rb'
        require_relative '../../model/season.rb'

        app.get '/api/rental-locations' do
          begin
            rental_locations = ::Model::RentalLocation.all
            content_type :json
            rental_locations.to_json
          rescue => e
            halt 500, { message: "Error al cargar las sucursales: #{e.message}" }.to_json
          end
        end

        app.get '/api/rate-types' do

          begin
            rental_location_id = params['rental-location-id'].to_i
            halt 400, { message: "The 'rental-location-id' parameter is required." }.to_json unless rental_location_id
            rate_type_ids = ::Model::CategoryRentalLocationRateType.all(rental_location_id: rental_location_id).map(&:rate_type_id).uniq
            halt 404, { message: "Rate types for location '#{rental_location_id}' not found." }.to_json if rate_type_ids.empty?
            rate_types = ::Model::RateType.all(:id => rate_type_ids)
            content_type :json
            rate_types.to_json
          rescue => e
            halt 500, { message: "Error al cargar las tarifas: #{e.message}" }.to_json
          end
        end

        app.get '/api/season-definitions' do

          begin
            rental_location_id = params['rental-location-id'].to_i
            halt 400, { message: "The 'rental-location-id' parameter is required." }.to_json unless rental_location_id

            rate_type_id = params['rate-type-id'].to_i
            halt 400, { message: "The 'rate-type-id' parameter is required." }.to_json unless rate_type_id
            
            price_definition_ids = ::Model::CategoryRentalLocationRateType
              .all(rental_location_id: rental_location_id)
              .all(rate_type_id: rate_type_id)
              .map(&:price_definition_id).uniq
            halt 404, { message: "Price Definitions for location '#{rental_location_id}' and rate type '#{rate_type_id}' not found." }.to_json if price_definition_ids.empty?

            season_definition_ids = ::Model::PriceDefinition.all(:id => price_definition_ids).map(&:season_definition_id).compact.uniq
            halt 404, { message: "Season Definitions for location '#{rental_location_id}' and rate type '#{rate_type_id}' not found." }.to_json if season_definition_ids.empty?
            
            season_definitions = ::Model::SeasonDefinition.all(:id => season_definition_ids)
            content_type :json
            season_definitions.to_json
          rescue => e
            halt 500, { message: "Error al cargar los grupos de temporada: #{e.message}" }.to_json
          end
        end

        app.get '/api/seasons' do

          begin
            season_definition_id = params['season-definition-id'].to_i
            halt 400, { message: "The 'season-definition-id' parameter is required." }.to_json unless season_definition_id

            seasons = ::Model::Season.all(season_definition_id: season_definition_id)            
            halt 404, { message: "Seasons for season definition '#{season_definition_id}' not found." }.to_json if seasons.empty?

            content_type :json
            seasons.to_json
          rescue => e
            halt 500, { message: "Error al cargar las temporadas: #{e.message}" }.to_json
          end
        end

      end
    end
  end
end

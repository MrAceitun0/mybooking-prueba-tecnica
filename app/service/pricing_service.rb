module Service
  module PricingService
    class << self
      
      def get_rental_locations
        begin
          locations = ::Model::RentalLocation.all
          raise Utils::NotFoundError.new('rental locations') if locations.empty?
          locations
        rescue DataObjects::Error => e
          raise Utils::DatabaseError.new("Failed to fetch rental locations: #{e.message}")
        end
      end

      def get_rate_types(rental_location_id)
        validate_rental_location_id(rental_location_id)
        
        begin
          rate_type_ids = ::Model::CategoryRentalLocationRateType
            .all(rental_location_id: rental_location_id)
            .map(&:rate_type_id)
            .uniq
          
          raise Utils::NotFoundError.new('rate types', "location '#{rental_location_id}'") if rate_type_ids.empty?
          
          rate_types = ::Model::RateType.all(:id => rate_type_ids)
          rate_types
        rescue DataObjects::Error => e
          raise Utils::DatabaseError.new("Failed to fetch rate types: #{e.message}")
        end
      end

      def get_season_definitions(rental_location_id, rate_type_id)
        validate_rental_location_id(rental_location_id)
        validate_rate_type_id(rate_type_id)
        
        begin
          price_definition_ids = ::Model::CategoryRentalLocationRateType
            .all(rental_location_id: rental_location_id)
            .all(rate_type_id: rate_type_id)
            .map(&:price_definition_id)
            .uniq
          
          raise Utils::NotFoundError.new('price definitions', "location '#{rental_location_id}' and rate type '#{rate_type_id}'") if price_definition_ids.empty?

          season_definition_ids = ::Model::PriceDefinition
            .all(:id => price_definition_ids)
            .map(&:season_definition_id)
            .compact
            .uniq
          
          raise Utils::NotFoundError.new('season definitions', "location '#{rental_location_id}' and rate type '#{rate_type_id}'") if season_definition_ids.empty?
          
          season_definitions = ::Model::SeasonDefinition.all(:id => season_definition_ids)
          season_definitions
        rescue DataObjects::Error => e
          raise Utils::DatabaseError.new("Failed to fetch season definitions: #{e.message}")
        end
      end

      def get_seasons(season_definition_id)
        validate_season_definition_id(season_definition_id)
        
        begin
          seasons = ::Model::Season.all(season_definition_id: season_definition_id)
          raise Utils::NotFoundError.new('seasons', "season definition '#{season_definition_id}'") if seasons.empty?
          seasons
        rescue DataObjects::Error => e
          raise Utils::DatabaseError.new("Failed to fetch seasons: #{e.message}")
        end
      end

      def get_vehicles(rental_location_id, rate_type_id, unit_id, season_definition_id = nil, season_id = nil)
        validate_rental_location_id(rental_location_id)
        validate_rate_type_id(rate_type_id)
        validate_unit_id(unit_id)
        
        begin
          unit_name = get_unit_name(unit_id)
          
          price_definition_ids = ::Model::CategoryRentalLocationRateType
            .all(rental_location_id: rental_location_id)
            .all(rate_type_id: rate_type_id)
            .map(&:price_definition_id)
            .uniq

          raise Utils::NotFoundError.new('price definitions', 'the given filters') if price_definition_ids.empty?

          price_definitions = if season_definition_id && season_definition_id != 'none'
            ::Model::PriceDefinition.all(:id => price_definition_ids, :season_definition_id => season_definition_id.to_i)
          else
            ::Model::PriceDefinition.all(:id => price_definition_ids)
          end

          raise Utils::NotFoundError.new('price definitions', 'the given season definition') if price_definitions.empty?

          vehicles_data = build_vehicles_data(price_definitions, rental_location_id, rate_type_id, unit_name, season_id)
          raise Utils::NotFoundError.new('vehicles', 'your conditions') if vehicles_data.empty?

          vehicles_data
        rescue DataObjects::Error => e
          raise Utils::DatabaseError.new("Failed to fetch vehicles: #{e.message}")
        end
      end

      private

      def validate_rental_location_id(rental_location_id)
        raise Utils::ValidationError.new("Rental location ID is required") if rental_location_id.nil? || rental_location_id.to_s.strip.empty?
        raise Utils::ValidationError.new("Rental location ID must be a valid integer") unless rental_location_id.to_s.match?(/^\d+$/)
      end

      def validate_rate_type_id(rate_type_id)
        raise Utils::ValidationError.new("Rate type ID is required") if rate_type_id.nil? || rate_type_id.to_s.strip.empty?
        raise Utils::ValidationError.new("Rate type ID must be a valid integer") unless rate_type_id.to_s.match?(/^\d+$/)
      end

      def validate_season_definition_id(season_definition_id)
        raise Utils::ValidationError.new("Season definition ID is required") if season_definition_id.nil? || season_definition_id.to_s.strip.empty?
        raise Utils::ValidationError.new("Season definition ID must be a valid integer") unless season_definition_id.to_s.match?(/^\d+$/)
      end

      def validate_unit_id(unit_id)
        raise Utils::ValidationError.new("Unit ID is required") if unit_id.nil? || unit_id.to_s.strip.empty?
        raise Utils::ValidationError.new("Unit ID must be a valid integer") unless unit_id.to_s.match?(/^\d+$/)
        raise Utils::ValidationError.new("Unit ID must be between 1 and 4") unless (1..4).include?(unit_id.to_i)
      end

      def get_unit_name(unit_id)
        case unit_id.to_i
        when 1 then :months
        when 2 then :days
        when 3 then :hours
        when 4 then :minutes
        else :days
        end
      end

      def build_vehicles_data(price_definitions, rental_location_id, rate_type_id, unit_name, season_id)
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
          
          if unit_name
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
        
        vehicles_data
      end
    end
  end
end

module Service
  class ImportPricesService
    attr_reader :errors, :imported_count, :updated_count, :skipped_count

    def initialize
      @errors = []
      @imported_count = 0
      @updated_count = 0
      @skipped_count = 0
    end

    def import_from_csv(csv_content)
      begin
        require 'csv'
        
        csv_data = CSV.parse(csv_content, headers: true, header_converters: :symbol)
        
        validate_headers(csv_data.headers)
        return false if @errors.any?

        csv_data.each_with_index do |row, index|
          process_row(row, index + 2) 
        end

        true
      rescue => e
        @errors << "Error parsing CSV: #{e.message}"
        false
      end
    end

    def import_from_file(file_path)
      begin
        csv_content = File.read(file_path)
        import_from_csv(csv_content)
      rescue => e
        @errors << "Error reading file: #{e.message}"
        false
      end
    end

    private

    def validate_headers(headers)
      required_headers = [:category_code, :rental_location_name, :rate_type_name, :season_name, :units, :price, :time_measurement]
      
      required_headers.each do |header|
        unless headers.include?(header)
          @errors << "Missing required header: #{header}"
        end
      end
    end

    def process_row(row, line_number)
      begin
        category_code = row[:category_code]&.strip
        rental_location_name = row[:rental_location_name]&.strip
        rate_type_name = row[:rate_type_name]&.strip
        season_name = row[:season_name]&.strip
        units = row[:units]&.to_i
        price = row[:price]&.to_f
        time_measurement = row[:time_measurement]&.to_i

        validate_row_data(category_code, rental_location_name, rate_type_name, units, price, time_measurement, line_number)
        return if @errors.any?

        price_definition = find_price_definition(category_code, rental_location_name, rate_type_name, line_number)
        return unless price_definition

        season = find_season(season_name, line_number) if season_name.present?

        unless should_import_price?(price_definition, units, line_number)
          @skipped_count += 1
          return
        end

        create_or_update_price(price_definition, season, units, price, time_measurement, line_number)

      rescue => e
        @errors << "Error processing line #{line_number}: #{e.message}"
      end
    end

    def validate_row_data(category_code, rental_location_name, rate_type_name, units, price, time_measurement, line_number)
      if category_code.blank?
        @errors << "Line #{line_number}: category_code is required"
      end

      if rental_location_name.blank?
        @errors << "Line #{line_number}: rental_location_name is required"
      end

      if rate_type_name.blank?
        @errors << "Line #{line_number}: rate_type_name is required"
      end

      if units.nil? || units <= 0
        @errors << "Line #{line_number}: units must be a positive integer"
      end

      if price.nil? || price < 0
        @errors << "Line #{line_number}: price must be a non-negative number"
      end

      if time_measurement.nil? || ![1, 2, 3, 4].include?(time_measurement)
        @errors << "Line #{line_number}: time_measurement must be 1 (months), 2 (days), 3 (hours), or 4 (minutes)"
      end
    end

    def find_price_definition(category_code, rental_location_name, rate_type_name, line_number)
      category = ::Model::Category.first(code: category_code)
      unless category
        @errors << "Line #{line_number}: Category with code '#{category_code}' not found"
        return nil
      end

      rental_location = ::Model::RentalLocation.first(name: rental_location_name)
      unless rental_location
        @errors << "Line #{line_number}: Rental location '#{rental_location_name}' not found"
        return nil
      end

      rate_type = ::Model::RateType.first(name: rate_type_name)
      unless rate_type
        @errors << "Line #{line_number}: Rate type '#{rate_type_name}' not found"
        return nil
      end

      relationship = ::Model::CategoryRentalLocationRateType.first(
        category_id: category.id,
        rental_location_id: rental_location.id,
        rate_type_id: rate_type.id
      )

      unless relationship
        @errors << "Line #{line_number}: No price definition found for category '#{category_code}', location '#{rental_location_name}', and rate type '#{rate_type_name}'"
        return nil
      end

      relationship.price_definition
    end

    def find_season(season_name, line_number)
      season = ::Model::Season.first(name: season_name)
      unless season
        @errors << "Line #{line_number}: Season '#{season_name}' not found"
        return nil
      end
      season
    end

    def should_import_price?(price_definition, units, line_number)
      existing_prices = ::Model::Price.all(price_definition_id: price_definition.id)
      existing_units = existing_prices.map(&:units).uniq.sort

      return true if existing_units.empty?

      if existing_units.include?(units)
        return true
      end

      @errors << "Line #{line_number}: Units '#{units}' not defined in price definition. Existing units: #{existing_units.join(', ')}"
      false
    end

    def create_or_update_price(price_definition, season, units, price, time_measurement, line_number)
      time_measurement_symbol = case time_measurement
      when 1 then :months
      when 2 then :days
      when 3 then :hours
      when 4 then :minutes
      end

      existing_price = ::Model::Price.first(
        price_definition_id: price_definition.id,
        season_id: season&.id,
        units: units,
        time_measurement: time_measurement_symbol
      )

      if existing_price
        existing_price.update(
          price: price,
          time_measurement: time_measurement_symbol
        )
        @updated_count += 1
      else
        ::Model::Price.create(
          price_definition_id: price_definition.id,
          season_id: season&.id,
          units: units,
          price: price,
          time_measurement: time_measurement_symbol
        )
        @imported_count += 1
      end
    end
  end
end

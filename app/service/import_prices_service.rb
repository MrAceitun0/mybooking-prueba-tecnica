module Service
  class ImportPricesService
    attr_reader :errors, :imported_count, :updated_count, :skipped_count

    REQUIRED_HEADERS = %i[
      category_code 
      rental_location_name 
      rate_type_name 
      season_name 
      units 
      price 
      time_measurement
    ].freeze

    TIME_MEASUREMENT_MAP = {
      1 => :months,
      2 => :days,
      3 => :hours,
      4 => :minutes
    }.freeze

    def initialize
      reset_counters
    end

    def import_from_file(file_path)
      csv_content = read_file_safely(file_path)
      return false unless csv_content

      import_from_csv(csv_content)
    end

    def import_from_csv(csv_content)
      csv_data = parse_csv_safely(csv_content)
      return false unless csv_data

      return false unless validate_headers(csv_data.headers)

      process_csv_rows(csv_data)
      true
    end

    private

    def reset_counters
      @errors = []
      @imported_count = 0
      @updated_count = 0
      @skipped_count = 0
    end

    def read_file_safely(file_path)
      File.read(file_path)
    rescue => e
      add_error("Error reading file: #{e.message}")
      nil
    end

    def parse_csv_safely(csv_content)
      require 'csv'
      CSV.parse(csv_content, headers: true, header_converters: :symbol)
    rescue => e
      add_error("Error parsing CSV: #{e.message}")
      nil
    end

    def validate_headers(headers)
      missing_headers = REQUIRED_HEADERS - headers
      missing_headers.each { |header| add_error("Missing required header: #{header}") }
      missing_headers.empty?
    end

    def process_csv_rows(csv_data)
      csv_data.each_with_index do |row, index|
        process_row(row, index + 2)
      end
    end

    def process_row(row, line_number)
      row_data = extract_row_data(row)
      return unless validate_row_data(row_data, line_number)

      price_definition = find_price_definition(row_data, line_number)
      return unless price_definition

      season = find_season(row_data[:season_name], line_number) if row_data[:season_name].present?
      return unless should_import_price?(price_definition, row_data[:units], line_number)

      create_or_update_price(price_definition, season, row_data, line_number)
    rescue => e
      add_error("Error processing line #{line_number}: #{e.message}")
    end

    def extract_row_data(row)
      {
        category_code: row[:category_code]&.strip,
        rental_location_name: row[:rental_location_name]&.strip,
        rate_type_name: row[:rate_type_name]&.strip,
        season_name: row[:season_name]&.strip,
        units: row[:units]&.to_i,
        price: row[:price]&.to_f,
        time_measurement: row[:time_measurement]&.to_i
      }
    end

    def validate_row_data(row_data, line_number)
      validations = [
        validate_required_field(:category_code, row_data[:category_code], line_number),
        validate_required_field(:rental_location_name, row_data[:rental_location_name], line_number),
        validate_required_field(:rate_type_name, row_data[:rate_type_name], line_number),
        validate_positive_integer(:units, row_data[:units], line_number),
        validate_non_negative_number(:price, row_data[:price], line_number),
        validate_time_measurement(row_data[:time_measurement], line_number)
      ]

      validations.all?
    end

    def validate_required_field(field_name, value, line_number)
      return true unless value.blank?

      add_error("Line #{line_number}: #{field_name} is required")
      false
    end

    def validate_positive_integer(field_name, value, line_number)
      return true if value&.positive?

      add_error("Line #{line_number}: #{field_name} must be a positive integer")
      false
    end

    def validate_non_negative_number(field_name, value, line_number)
      return true if value&.>= 0

      add_error("Line #{line_number}: #{field_name} must be a non-negative number")
      false
    end

    def validate_time_measurement(value, line_number)
      return true if TIME_MEASUREMENT_MAP.key?(value)

      add_error("Line #{line_number}: time_measurement must be 1 (months), 2 (days), 3 (hours), or 4 (minutes)")
      false
    end

    def find_price_definition(row_data, line_number)
      category = find_model(::Model::Category, :code, row_data[:category_code], line_number, "Category")
      return nil unless category

      rental_location = find_model(::Model::RentalLocation, :name, row_data[:rental_location_name], line_number, "Rental location")
      return nil unless rental_location

      rate_type = find_model(::Model::RateType, :name, row_data[:rate_type_name], line_number, "Rate type")
      return nil unless rate_type

      find_price_definition_relationship(category, rental_location, rate_type, row_data, line_number)
    end

    def find_model(model_class, field, value, line_number, model_name)
      model = model_class.first(field => value)
      return model if model

      add_error("Line #{line_number}: #{model_name} '#{value}' not found")
      nil
    end

    def find_price_definition_relationship(category, rental_location, rate_type, row_data, line_number)
      relationship = ::Model::CategoryRentalLocationRateType.first(
        category_id: category.id,
        rental_location_id: rental_location.id,
        rate_type_id: rate_type.id
      )

      return relationship.price_definition if relationship

      add_error("Line #{line_number}: No price definition found for category '#{row_data[:category_code]}', location '#{row_data[:rental_location_name]}', and rate type '#{row_data[:rate_type_name]}'")
      nil
    end

    def find_season(season_name, line_number)
      return nil if season_name.blank?

      find_model(::Model::Season, :name, season_name, line_number, "Season")
    end

    def should_import_price?(price_definition, units, line_number)
      existing_units = get_existing_units(price_definition)
      return true if existing_units.empty?
      return true if existing_units.include?(units)

      add_error("Line #{line_number}: Units '#{units}' not defined in price definition. Existing units: #{existing_units.join(', ')}")
      @skipped_count += 1
      false
    end

    def get_existing_units(price_definition)
      ::Model::Price
        .all(price_definition_id: price_definition.id)
        .map(&:units)
        .uniq
        .sort
    end

    def create_or_update_price(price_definition, season, row_data, line_number)
      time_measurement_symbol = TIME_MEASUREMENT_MAP[row_data[:time_measurement]]
      
      existing_price = find_existing_price(price_definition, season, row_data, time_measurement_symbol)

      if existing_price
        update_existing_price(existing_price, row_data, time_measurement_symbol)
      else
        create_new_price(price_definition, season, row_data, time_measurement_symbol)
      end
    end

    def find_existing_price(price_definition, season, row_data, time_measurement_symbol)
      ::Model::Price.first(
        price_definition_id: price_definition.id,
        season_id: season&.id,
        units: row_data[:units],
        time_measurement: time_measurement_symbol
      )
    end

    def update_existing_price(existing_price, row_data, time_measurement_symbol)
      existing_price.update(
        price: row_data[:price],
        time_measurement: time_measurement_symbol
      )
      @updated_count += 1
    end

    def create_new_price(price_definition, season, row_data, time_measurement_symbol)
      ::Model::Price.create(
        price_definition_id: price_definition.id,
        season_id: season&.id,
        units: row_data[:units],
        price: row_data[:price],
        time_measurement: time_measurement_symbol
      )
      @imported_count += 1
    end

    def add_error(message)
      @errors << message
    end
  end
end

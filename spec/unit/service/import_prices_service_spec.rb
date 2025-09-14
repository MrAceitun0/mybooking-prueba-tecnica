require 'spec_helper'
require_relative '../../../app/utils/custom_errors'

RSpec.describe Service::ImportPricesService, type: :unit do
  let(:service) { described_class.new }
  
  let(:categories) do
    [
      double('Category', id: 1, code: 'TURISMO', name: 'Turismo'),
      double('Category', id: 2, code: 'SCOOTER', name: 'Scooter'),
      double('Category', id: 3, code: '4X4', name: '4x4')
    ]
  end

  let(:rental_locations) do
    [
      double('RentalLocation', id: 1, name: 'Mao'),
      double('RentalLocation', id: 2, name: 'Sant Lluis'),
      double('RentalLocation', id: 3, name: 'El Toro')
    ]
  end

  let(:rate_types) do
    [
      double('RateType', id: 1, name: 'Estándar'),
      double('RateType', id: 2, name: 'Premium'),
      double('RateType', id: 3, name: 'Fin de semana')
    ]
  end

  let(:seasons) do
    [
      double('Season', id: 1, name: 'Alta'),
      double('Season', id: 2, name: 'Media'),
      double('Season', id: 3, name: 'Baja')
    ]
  end

  let(:price_definitions) do
    [
      double('PriceDefinition', id: 1, name: 'Standard Definition'),
      double('PriceDefinition', id: 2, name: 'Premium Definition')
    ]
  end

  let(:category_rental_location_rate_types) do
    [
      double('CategoryRentalLocationRateType', 
        id: 1, 
        category_id: 1, 
        rental_location_id: 1, 
        rate_type_id: 1, 
        price_definition: price_definitions[0]
      ),
      double('CategoryRentalLocationRateType', 
        id: 2, 
        category_id: 2, 
        rental_location_id: 2, 
        rate_type_id: 2, 
        price_definition: price_definitions[1]
      )
    ]
  end

  let(:existing_prices) do
    [
      double('Price', id: 1, units: 1, time_measurement: :days, price: 50.0),
      double('Price', id: 2, units: 2, time_measurement: :days, price: 90.0)
    ]
  end

  let(:valid_csv_content) do
    <<~CSV
      category_code,rental_location_name,rate_type_name,season_name,units,price,time_measurement
      TURISMO,Mao,Estándar,Alta,1,50.0,2
      SCOOTER,Sant Lluis,Premium,Media,2,75.0,2
      4X4,El Toro,Fin de semana,,3,100.0,3
    CSV
  end

  let(:invalid_csv_content) do
    <<~CSV
      category_code,rental_location_name,rate_type_name,units,price
      TURISMO,Mao,Estándar,1,50.0
    CSV
  end

  describe '#initialize' do
    it 'initializes with empty counters and errors' do
      expect(service.errors).to eq([])
      expect(service.imported_count).to eq(0)
      expect(service.updated_count).to eq(0)
      expect(service.skipped_count).to eq(0)
    end
  end

  describe '#import_from_file' do
    context 'when file exists and is valid' do
      it 'successfully imports from file' do
        allow(File).to receive(:read)
            .with('test.csv')
            .and_return(valid_csv_content)
        allow(service).to receive(:import_from_csv)
            .with(valid_csv_content)
            .and_return(true)

        result = service.import_from_file('test.csv')

        expect(result).to be true
        expect(File).to have_received(:read).with('test.csv')
        expect(service).to have_received(:import_from_csv).with(valid_csv_content)
      end
    end

    context 'when file does not exist' do
      it 'handles file reading error' do
        allow(File).to receive(:read)
            .with('nonexistent.csv')
            .and_raise(Errno::ENOENT, 'No such file')

        result = service.import_from_file('nonexistent.csv')

        expect(result).to be false
        expect(service.errors).to include(/Error reading file: No such file/)
      end
    end
  end

  describe '#import_from_csv' do
    context 'with valid CSV content' do
      before do
        allow(service).to receive(:parse_csv_safely)
            .and_return(double('CSV', headers: described_class::REQUIRED_HEADERS))
        allow(service).to receive(:process_csv_rows)
      end

      it 'successfully processes valid CSV' do
        result = service.import_from_csv(valid_csv_content)

        expect(result).to be true
        expect(service).to have_received(:parse_csv_safely).with(valid_csv_content)
        expect(service).to have_received(:process_csv_rows)
      end
    end

    context 'with invalid CSV content' do
      it 'handles CSV parsing errors' do
        allow(service).to receive(:parse_csv_safely)
            .and_return(nil)

        result = service.import_from_csv('invalid,csv,content')

        expect(result).to be false
        expect(service).to have_received(:parse_csv_safely).with('invalid,csv,content')
      end

      it 'handles missing headers' do
        incomplete_csv_content = <<~CSV
          category_code,rental_location_name
          TURISMO,Mao
        CSV
        
        csv_data = double('CSV', headers: [:category_code, :rental_location_name])
        allow(service).to receive(:parse_csv_safely)
            .with(incomplete_csv_content)
            .and_return(csv_data)

        result = service.import_from_csv(incomplete_csv_content)

        expect(result).to be false
        expect(service.errors).to include(/Missing required header: rate_type_name/)
        expect(service.errors).to include(/Missing required header: season_name/)
        expect(service.errors).to include(/Missing required header: units/)
        expect(service.errors).to include(/Missing required header: price/)
        expect(service.errors).to include(/Missing required header: time_measurement/)
      end
    end
  end

  describe 'row data validation' do
    let(:valid_row_data) do
      {
        category_code: 'TURISMO',
        rental_location_name: 'Mao',
        rate_type_name: 'Estándar',
        season_name: 'Alta',
        units: 1,
        price: 50.0,
        time_measurement: 2
      }
    end

    describe '#validate_row_data' do
      it 'validates all required fields are present' do
        result = service.send(:validate_row_data, valid_row_data, 1)

        expect(result).to be true
        expect(service.errors).to be_empty
      end

      it 'fails validation when required fields are missing' do
        invalid_row_data = valid_row_data.merge(category_code: nil)

        result = service.send(:validate_row_data, invalid_row_data, 1)

        expect(result).to be false
        expect(service.errors).to include(/Line 1: category_code is required/)
      end

      it 'fails validation when units is not positive' do
        invalid_row_data = valid_row_data.merge(units: 0)

        result = service.send(:validate_row_data, invalid_row_data, 1)

        expect(result).to be false
        expect(service.errors).to include(/Line 1: units must be a positive integer/)
      end

      it 'fails validation when price is negative' do
        invalid_row_data = valid_row_data.merge(price: -10.0)

        result = service.send(:validate_row_data, invalid_row_data, 1)

        expect(result).to be false
        expect(service.errors).to include(/Line 1: price must be a non-negative number/)
      end

      it 'fails validation when time_measurement is invalid' do
        invalid_row_data = valid_row_data.merge(time_measurement: 5)

        result = service.send(:validate_row_data, invalid_row_data, 1)

        expect(result).to be false
        expect(service.errors).to include(/Line 1: time_measurement must be 1 \(months\), 2 \(days\), 3 \(hours\), or 4 \(minutes\)/)
      end
    end
  end

  describe 'model lookups' do
    describe '#find_model' do
      it 'finds existing model' do
        allow(::Model::Category).to receive(:first).with(code: 'TURISMO').and_return(categories[0])

        result = service.send(:find_model, ::Model::Category, :code, 'TURISMO', 1, 'Category')

        expect(result).to eq(categories[0])
        expect(::Model::Category).to have_received(:first).with(code: 'TURISMO')
      end

      it 'adds error when model not found' do
        allow(::Model::Category).to receive(:first).with(code: 'INVALID').and_return(nil)

        result = service.send(:find_model, ::Model::Category, :code, 'INVALID', 1, 'Category')

        expect(result).to be_nil
        expect(service.errors).to include(/Line 1: Category 'INVALID' not found/)
      end
    end

    describe '#find_price_definition' do
      let(:row_data) do
        {
          category_code: 'TURISMO',
          rental_location_name: 'Mao',
          rate_type_name: 'Estándar'
        }
      end

      it 'finds price definition when all models exist' do
        allow(::Model::Category).to receive(:first).with(code: 'TURISMO').and_return(categories[0])
        allow(::Model::RentalLocation).to receive(:first).with(name: 'Mao').and_return(rental_locations[0])
        allow(::Model::RateType).to receive(:first).with(name: 'Estándar').and_return(rate_types[0])
        allow(::Model::CategoryRentalLocationRateType).to receive(:first).and_return(category_rental_location_rate_types[0])

        result = service.send(:find_price_definition, row_data, 1)

        expect(result).to eq(price_definitions[0])
      end

      it 'adds error when category not found' do
        allow(::Model::Category).to receive(:first).with(code: 'INVALID').and_return(nil)

        result = service.send(:find_price_definition, row_data.merge(category_code: 'INVALID'), 1)

        expect(result).to be_nil
        expect(service.errors).to include(/Line 1: Category 'INVALID' not found/)
      end

      it 'adds error when price definition relationship not found' do
        allow(::Model::Category).to receive(:first).and_return(categories[0])
        allow(::Model::RentalLocation).to receive(:first).and_return(rental_locations[0])
        allow(::Model::RateType).to receive(:first).and_return(rate_types[0])
        allow(::Model::CategoryRentalLocationRateType).to receive(:first).and_return(nil)

        result = service.send(:find_price_definition, row_data, 1)

        expect(result).to be_nil
        expect(service.errors).to include(/Line 1: No price definition found for category 'TURISMO', location 'Mao', and rate type 'Estándar'/)
      end
    end
  end

  describe 'price creation and updating' do
    let(:row_data) do
      {
        units: 1,
        price: 50.0,
        time_measurement: 2
      }
    end

    describe '#should_import_price?' do
      it 'allows import when no existing prices' do
        allow(service).to receive(:get_existing_units)
            .with(price_definitions[0])
            .and_return([])

        result = service.send(:should_import_price?, price_definitions[0], 1, 1)

        expect(result).to be true
      end

      it 'allows import when units already exist' do
        allow(service).to receive(:get_existing_units)
            .with(price_definitions[0])
            .and_return([1, 2])

        result = service.send(:should_import_price?, price_definitions[0], 1, 1)

        expect(result).to be true
      end

      it 'skips import when units not defined in price definition' do
        allow(service).to receive(:get_existing_units)
            .with(price_definitions[0])
            .and_return([1, 2])

        result = service.send(:should_import_price?, price_definitions[0], 3, 1)

        expect(result).to be false
        expect(service.skipped_count).to eq(1)
        expect(service.errors).to include(/Line 1: Units '3' not defined in price definition. Existing units: 1, 2/)
      end
    end

    describe '#create_or_update_price' do
      context 'when price already exists' do
        it 'updates existing price and increments counter' do
          existing_price = double('Price')
          allow(existing_price).to receive(:update)
                    allow(::Model::Price).to receive(:first).and_return(existing_price)

          service.send(:create_or_update_price, price_definitions[0], seasons[0], row_data, 1)

          expect(existing_price).to have_received(:update).with(
            price: 50.0,
            time_measurement: :days
          )
          
          expect(service.updated_count).to eq(1)
          expect(service.imported_count).to eq(0) 
        end
      end

      context 'when price does not exist' do
        it 'creates new price and increments counter' do
          allow(::Model::Price).to receive(:first).and_return(nil)
          allow(::Model::Price).to receive(:create).and_return(double('Price'))

          service.send(:create_or_update_price, price_definitions[0], seasons[0], row_data, 1)

          expect(::Model::Price).to have_received(:create).with(
            price_definition_id: 1,
            season_id: 1,
            units: 1,
            price: 50.0,
            time_measurement: :days
          )
          
          expect(service.imported_count).to eq(1)
          expect(service.updated_count).to eq(0) # Should not increment update counter
        end

        it 'creates new price without season and increments counter' do
            allow(::Model::Price).to receive(:first).and_return(nil)
            allow(::Model::Price).to receive(:create).and_return(double('Price'))
  
            service.send(:create_or_update_price, price_definitions[0], nil, row_data, 1)
  
            expect(::Model::Price).to have_received(:create).with(
              price_definition_id: 1,
              season_id: nil,
              units: 1,
              price: 50.0,
              time_measurement: :days
            )
            
            expect(service.imported_count).to eq(1)
            expect(service.updated_count).to eq(0) # Should not increment update counter
          end
      end
    end
  end
end

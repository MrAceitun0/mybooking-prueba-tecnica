require 'spec_helper'
require_relative '../../../app/utils/custom_errors'

RSpec.describe Service::PricingService, type: :unit do
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

  let(:categories) do
    [
      double('Category', id: 1, name: 'Turismo'),
      double('Category', id: 2, name: 'Scooter'),
      double('Category', id: 3, name: '4x4')
    ]
  end

  let(:season_definitions) do
    [
      double('SeasonDefinition', id: 1, name: 'Verano'),
      double('SeasonDefinition', id: 2, name: 'Invierno'),
      double('SeasonDefinition', id: 3, name: 'Navidad')
    ]
  end

  let(:seasons) do
    [
      double('Season', id: 1, name: 'Alta', season_definition_id: 1),
      double('Season', id: 2, name: 'Media', season_definition_id: 1),
      double('Season', id: 3, name: 'Baja', season_definition_id: 2)
    ]
  end

  let(:price_definitions) do
    [
      double('PriceDefinition', id: 1, season_definition_id: 1),
      double('PriceDefinition', id: 2, season_definition_id: 2),
      double('PriceDefinition', id: 3, season_definition_id: nil)
    ]
  end

  let(:prices) do
    [
      double('Price', id: 1, units: 1, time_measurement: :days, price: 50.0, season_id: 1, price_definition_id: 1),
      double('Price', id: 2, units: 2, time_measurement: :days, price: 90.0, season_id: 1, price_definition_id: 1),
      double('Price', id: 3, units: 1, time_measurement: :hours, price: 15.0, season_id: 2, price_definition_id: 2)
    ]
  end

  let(:category_rental_location_rate_types) do
    [
      double('CategoryRentalLocationRateType', id: 1, category_id: 1, rental_location_id: 1, rate_type_id: 1, price_definition_id: 1),
      double('CategoryRentalLocationRateType', id: 2, category_id: 2, rental_location_id: 1, rate_type_id: 2, price_definition_id: 2),
      double('CategoryRentalLocationRateType', id: 3, category_id: 3, rental_location_id: 2, rate_type_id: 1, price_definition_id: 3)
    ]
  end

  describe '.get_rental_locations' do
    context 'when locations exist' do
      it 'returns all rental locations with correct names' do
        allow(::Model::RentalLocation).to receive(:all).and_return(rental_locations)

        result = described_class.get_rental_locations

        expect(result).to eq(rental_locations)
        expect(result.length).to eq(3)
        expect(result.map(&:name)).to contain_exactly('Mao', 'Sant Lluis', 'El Toro')
        expect(::Model::RentalLocation).to have_received(:all)
      end
    end

    context 'when no locations exist' do
      it 'raises NotFoundError' do
        allow(::Model::RentalLocation).to receive(:all).and_return([])

        expect {
          described_class.get_rental_locations
        }.to raise_error(Utils::NotFoundError, "Rental locations not found.")
      end
    end

    context 'when database error occurs' do
      it 'raises DatabaseError' do
        allow(::Model::RentalLocation).to receive(:all).and_raise(DataObjects::Error.new('Connection failed'))

        expect {
          described_class.get_rental_locations
        }.to raise_error(Utils::DatabaseError, 'Failed to fetch rental locations: Connection failed')
      end
    end
  end

  describe '.get_rate_types' do
    context 'when rate types exist for location' do
      it 'returns rate types filtered by location when multiple rate types exist' do
        location_rate_types = category_rental_location_rate_types.select { |c| c.rental_location_id == 1 }
        allow(::Model::CategoryRentalLocationRateType).to receive(:all)
          .with(rental_location_id: 1)
          .and_return(location_rate_types)
        
        expected_rate_types = rate_types.select { |rt| [1, 2].include?(rt.id) }
        allow(::Model::RateType).to receive(:all).with(:id => [1, 2]).and_return(expected_rate_types)

        result = described_class.get_rate_types(1)

        expect(result.length).to eq(2)
        expect(result.map(&:name)).to contain_exactly('Estándar', 'Premium')
        expect(::Model::CategoryRentalLocationRateType).to have_received(:all).with(rental_location_id: 1)
        expect(::Model::RateType).to have_received(:all).with(:id => [1, 2])
      end

      it 'returns rate types filtered by location when only one rate type exists' do
        location_rate_types = category_rental_location_rate_types.select { |c| c.rental_location_id == 2 }
        allow(::Model::CategoryRentalLocationRateType).to receive(:all)
          .with(rental_location_id: 2)
          .and_return(location_rate_types)
        
        expected_rate_types = rate_types.select { |rt| rt.id == 1 }
        allow(::Model::RateType).to receive(:all).with(:id => [1]).and_return(expected_rate_types)

        result = described_class.get_rate_types(2)

        expect(result.length).to eq(1)
        expect(result.first.name).to eq('Estándar')
      end
    end

    context 'when no rate types exist for location' do
      it 'raises NotFoundError' do
        allow(::Model::CategoryRentalLocationRateType).to receive(:all)
          .with(rental_location_id: 999)
          .and_return([])

        expect {
          described_class.get_rate_types(999)
        }.to raise_error(Utils::NotFoundError, "Rate types 'location '999'' not found.")
      end
    end

    context 'when database error occurs' do
      it 'raises DatabaseError' do
        allow(::Model::CategoryRentalLocationRateType).to receive(:all)
          .with(rental_location_id: 1)
          .and_raise(DataObjects::Error.new('Query failed'))

        expect {
          described_class.get_rate_types(1)
        }.to raise_error(Utils::DatabaseError, 'Failed to fetch rate types: Query failed')
      end
    end
  end

  describe '.get_season_definitions' do
    context 'when season definitions exist' do
      it 'returns season definitions filtered by location and rate type with correct names' do
        allow(described_class).to receive(:get_price_definition_ids).with(1, 1).and_return([1, 2])
        allow(described_class).to receive(:get_season_definition_ids).with([1, 2]).and_return([1, 2])
        expected_season_definitions = season_definitions.select { |sd| [1, 2].include?(sd.id) }
        allow(::Model::SeasonDefinition).to receive(:all).with(:id => [1, 2]).and_return(expected_season_definitions)

        result = described_class.get_season_definitions(1, 1)

        expect(result.length).to eq(2)
        expect(result.map(&:name)).to contain_exactly('Verano', 'Invierno')
        expect(::Model::SeasonDefinition).to have_received(:all).with(:id => [1, 2])
      end
    end

    context 'when no price definitions exist' do
      it 'raises NotFoundError for missing price definitions' do
        allow(described_class).to receive(:get_price_definition_ids).with(1, 2).and_return([])

        expect {
          described_class.get_season_definitions(1, 2)
        }.to raise_error(Utils::NotFoundError, "Price definitions 'location '1' and rate type '2'' not found.")
      end
    end

    context 'when no season definitions exist' do
      it 'raises NotFoundError for missing season definitions' do
        allow(described_class).to receive(:get_price_definition_ids).with(1, 2).and_return([1, 2])
        allow(described_class).to receive(:get_season_definition_ids).with([1, 2]).and_return([])

        expect {
          described_class.get_season_definitions(1, 2)
        }.to raise_error(Utils::NotFoundError, "Season definitions 'location '1' and rate type '2'' not found.")
      end
    end
  end

  describe '.get_seasons' do
    context 'when seasons exist for season definition' do
      it 'returns seasons filtered by season definition with correct names' do
        expected_seasons = seasons.select { |s| s.season_definition_id == 1 }
        allow(::Model::Season).to receive(:all).with(season_definition_id: 1).and_return(expected_seasons)

        result = described_class.get_seasons(1)

        expect(result.length).to eq(2)
        expect(result.map(&:name)).to contain_exactly('Alta', 'Media')
        expect(::Model::Season).to have_received(:all).with(season_definition_id: 1)
      end

      it 'returns different seasons for different season definitions' do
        expected_seasons = seasons.select { |s| s.season_definition_id == 2 }
        allow(::Model::Season).to receive(:all).with(season_definition_id: 2).and_return(expected_seasons)

        result = described_class.get_seasons(2)

        expect(result.length).to eq(1)
        expect(result.first.name).to eq('Baja')
      end
    end

    context 'when no seasons exist for season definition' do
      it 'raises NotFoundError' do
        allow(::Model::Season).to receive(:all).with(season_definition_id: 999).and_return([])

        expect {
          described_class.get_seasons(999)
        }.to raise_error(Utils::NotFoundError, "Seasons 'season definition '999'' not found.")
      end
    end
  end

  describe '.get_vehicles' do
    context 'when vehicles exist with valid filters' do
      it 'returns vehicles data with correct category names and prices' do
        allow(described_class).to receive(:get_price_definition_ids).with(1, 1).and_return([1, 2])
        allow(described_class).to receive(:get_price_definitions_by_season_definition).with([1, 2], nil).and_return(price_definitions[0..1])
        
        expected_vehicles = [
          {
            id: 1,
            name: 'Turismo',
            prices: [
              { id: 1, amount: 1, unit: :days, price: 50.0 },
              { id: 2, amount: 2, unit: :days, price: 90.0 }
            ]
          },
          {
            id: 2,
            name: 'Scooter',
            prices: [
              { id: 3, amount: 1, unit: :hours, price: 15.0 }
            ]
          }
        ]
        allow(described_class).to receive(:build_vehicles_data).and_return(expected_vehicles)

        result = described_class.get_vehicles(1, 1, 2)

        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result.map { |v| v[:name] }).to contain_exactly('Turismo', 'Scooter')
        
        # Test Economy Car prices
        economy_car = result.find { |v| v[:name] == 'Turismo' }
        expect(economy_car[:prices]).to be_an(Array)
        expect(economy_car[:prices].length).to eq(2)
        expect(economy_car[:prices].first[:id]).to eq(1)
        expect(economy_car[:prices].first[:amount]).to eq(1)
        expect(economy_car[:prices].first[:unit]).to eq(:days)
        expect(economy_car[:prices].first[:price]).to eq(50.0)
        expect(economy_car[:prices].last[:id]).to eq(2)
        expect(economy_car[:prices].last[:amount]).to eq(2)
        expect(economy_car[:prices].last[:unit]).to eq(:days)
        expect(economy_car[:prices].last[:price]).to eq(90.0)
        
        # Test Luxury Sedan prices
        scooter = result.find { |v| v[:name] == 'Scooter' }
        expect(scooter[:prices]).to be_an(Array)
        expect(scooter[:prices].length).to eq(1)
        expect(scooter[:prices].first[:id]).to eq(3)
        expect(scooter[:prices].first[:amount]).to eq(1)
        expect(scooter[:prices].first[:unit]).to eq(:hours)
        expect(scooter[:prices].first[:price]).to eq(15.0)
      end
    end

    context 'when filtering by season definition' do
      it 'returns vehicles filtered by season definition' do
        allow(described_class).to receive(:get_price_definition_ids).with(1, 1).and_return([1, 2])
        allow(described_class).to receive(:get_price_definitions_by_season_definition).with([1, 2], 1).and_return([price_definitions[0]])
        
        expected_vehicles = [
          {
            id: 1,
            name: 'Turismo',
            prices: [{ id: 1, amount: 1, unit: :days, price: 50.0 }]
          }
        ]
        allow(described_class).to receive(:build_vehicles_data).and_return(expected_vehicles)

        result = described_class.get_vehicles(1, 1, 2, 1)

        expect(result.length).to eq(1)
        expect(result.first[:name]).to eq('Turismo')
        
        # Test Economy Car price details
        economy_car = result.first
        expect(economy_car[:prices]).to be_an(Array)
        expect(economy_car[:prices].length).to eq(1)
        expect(economy_car[:prices].first[:id]).to eq(1)
        expect(economy_car[:prices].first[:amount]).to eq(1)
        expect(economy_car[:prices].first[:unit]).to eq(:days)
        expect(economy_car[:prices].first[:price]).to eq(50.0)
      end
    end

    context 'when no price definitions exist' do
      it 'raises NotFoundError' do
        allow(described_class).to receive(:get_price_definition_ids).with(1, 2).and_return([])

        expect {
          described_class.get_vehicles(1, 2, 2)
        }.to raise_error(Utils::NotFoundError, "Price definitions 'the given filters' not found.")
      end
    end

    context 'when no vehicles match conditions' do
      it 'raises NotFoundError' do
        allow(described_class).to receive(:get_price_definition_ids).with(1, 2).and_return([1])
        allow(described_class).to receive(:get_price_definitions_by_season_definition).with([1], nil).and_return([price_definitions[0]])
        allow(described_class).to receive(:build_vehicles_data).and_return([])

        expect {
          described_class.get_vehicles(1, 2, 2)
        }.to raise_error(Utils::NotFoundError, "Vehicles 'your conditions' not found.")
      end
    end
  end
end

require 'spec_helper'
require_relative '../../../app/utils/custom_errors'

RSpec.describe 'Pricing Dashboard End-to-End Journey', type: :unit do
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
      double('Price', id: 3, units: 1, time_measurement: :hours, price: 15.0, season_id: 2, price_definition_id: 2),
      double('Price', id: 4, units: 3, time_measurement: :days, price: 120.0, season_id: 1, price_definition_id: 1)
    ]
  end

  let(:category_rental_location_rate_types) do
    [
      double('CategoryRentalLocationRateType', id: 1, category_id: 1, rental_location_id: 1, rate_type_id: 1, price_definition_id: 1, category: categories[0]),
      double('CategoryRentalLocationRateType', id: 2, category_id: 2, rental_location_id: 1, rate_type_id: 2, price_definition_id: 2, category: categories[1]),
      double('CategoryRentalLocationRateType', id: 3, category_id: 3, rental_location_id: 2, rate_type_id: 1, price_definition_id: 3, category: categories[2])
    ]
  end

  let(:vehicles_data) do
    vehicles_data = [
        {
          id: 1,
          name: 'Turismo',
          prices: [
            { id: 1, amount: 1, unit: :days, price: 50.0 },
            { id: 2, amount: 2, unit: :days, price: 90.0 },
            { id: 4, amount: 3, unit: :days, price: 120.0 }
          ]
        }
      ]
  end

  describe 'Complete pricing dashboard journey' do
    it 'successfully completes the full user journey from rental locations to vehicles' do
      # Get all rental locations
      allow(::Model::RentalLocation).to receive(:all)
        .and_return(rental_locations)

      rental_locations_result = Service::PricingService.get_rental_locations

      expect(rental_locations_result).to eq(rental_locations)
      expect(rental_locations_result.length).to eq(3)
      expect(rental_locations_result.map(&:name)).to contain_exactly('Mao', 'Sant Lluis', 'El Toro')
      
      #User selects Mao (location_id: 1) and gets rate types for that location
      allow(::Model::CategoryRentalLocationRateType).to receive(:all)
        .with(rental_location_id: 1)
        .and_return(category_rental_location_rate_types.select { |c| c.rental_location_id == 1 })
      allow(::Model::RateType).to receive(:all)
        .with(:id => [1, 2])
        .and_return(rate_types.select { |rt| [1, 2].include?(rt.id) })

      rate_types_result = Service::PricingService.get_rate_types(1)

      expect(rate_types_result.length).to eq(2)
      expect(rate_types_result.map(&:name)).to contain_exactly('Estándar', 'Premium')
      
      # Step 3: User selects Estándar (rate_type_id: 1) and gets season definitions
      allow(Service::PricingService).to receive(:get_price_definition_ids)
        .with(1, 1)
        .and_return([1, 2])
      allow(Service::PricingService).to receive(:get_season_definition_ids)
        .with([1, 2])
        .and_return([1, 2])
      allow(::Model::SeasonDefinition).to receive(:all)
        .with(:id => [1, 2])
        .and_return(season_definitions.select { |sd| [1, 2].include?(sd.id) })
      season_definitions_result = Service::PricingService.get_season_definitions(1, 1)
      expect(season_definitions_result.length).to eq(2)
      expect(season_definitions_result.map(&:name)).to contain_exactly('Verano', 'Invierno')
      
      # Step 4: User selects Verano (season_definition_id: 1) and gets seasons
      allow(::Model::Season).to receive(:all)
        .with(season_definition_id: 1)
        .and_return(seasons.select { |s| s.season_definition_id == 1 })
      
      seasons_result = Service::PricingService.get_seasons(1)
      
      expect(seasons_result.length).to eq(2)
      expect(seasons_result.map(&:name)).to contain_exactly('Alta', 'Media')
      
      # Step 5: User selects Alta (season_id: 1), unit 2 (days), and gets vehicles
      allow(Service::PricingService).to receive(:get_price_definition_ids)
        .with(1, 1)
        .and_return([1, 2])
      allow(Service::PricingService).to receive(:get_price_definitions_by_season_definition)
        .with([1, 2], 1)
        .and_return([price_definitions[0]])
      
      allow(Service::PricingService).to receive(:build_vehicles_data)
        .and_return(vehicles_data)
      
      vehicles_result = Service::PricingService.get_vehicles(1, 1, 2, 1, 1)
      
      # Assert that the vehicles data is returned
      expect(vehicles_result).to be_an(Array)
      expect(vehicles_result.length).to eq(1)
      
      turismo_vehicle = vehicles_result.first
      expect(turismo_vehicle[:name]).to eq('Turismo')
      expect(turismo_vehicle[:prices]).to be_an(Array)
      expect(turismo_vehicle[:prices].length).to eq(3)
      
      # Verify all price details
      expect(turismo_vehicle[:prices].first[:id]).to eq(1)
      expect(turismo_vehicle[:prices].first[:amount]).to eq(1)
      expect(turismo_vehicle[:prices].first[:unit]).to eq(:days)
      expect(turismo_vehicle[:prices].first[:price]).to eq(50.0)
      
      expect(turismo_vehicle[:prices][1][:id]).to eq(2)
      expect(turismo_vehicle[:prices][1][:amount]).to eq(2)
      expect(turismo_vehicle[:prices][1][:unit]).to eq(:days)
      expect(turismo_vehicle[:prices][1][:price]).to eq(90.0)
      
      expect(turismo_vehicle[:prices].last[:id]).to eq(4)
      expect(turismo_vehicle[:prices].last[:amount]).to eq(3)
      expect(turismo_vehicle[:prices].last[:unit]).to eq(:days)
      expect(turismo_vehicle[:prices].last[:price]).to eq(120.0)
      
      # Verify that all service methods were called with correct parameters
      expect(::Model::RentalLocation).to have_received(:all)
      expect(::Model::CategoryRentalLocationRateType).to have_received(:all).with(rental_location_id: 1)
      expect(::Model::RateType).to have_received(:all).with(:id => [1, 2])
      expect(Service::PricingService).to have_received(:get_price_definition_ids).with(1, 1).twice
      expect(Service::PricingService).to have_received(:get_season_definition_ids).with([1, 2])
      expect(::Model::SeasonDefinition).to have_received(:all).with(:id => [1, 2])
      expect(::Model::Season).to have_received(:all).with(season_definition_id: 1)
      expect(Service::PricingService).to have_received(:get_price_definitions_by_season_definition).with([1, 2], 1)
      expect(Service::PricingService).to have_received(:build_vehicles_data)
    end
  end
end

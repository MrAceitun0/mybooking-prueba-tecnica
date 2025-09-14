require 'spec_helper'
require_relative '../../../app/utils/custom_errors'

RSpec.describe Utils::ParameterValidator, type: :unit do

  describe '.validate_required_params' do
    context 'with valid parameters' do

      it 'passes validation for multiple present parameters' do
        params = { 
          'rental-location-id' => '1',
          'rate-type-id' => '2',
          'unit-id' => '2'
        }
        
        expect {
          described_class.validate_required_params(params, 'rental-location-id', 'rate-type-id', 'unit-id')
        }.not_to raise_error
      end
    end

    context 'with missing parameters' do
      it 'raises ValidationError for missing parameter' do
        params = {}
        
        expect {
          described_class.validate_required_params(params, 'rental-location-id')
        }.to raise_error(Utils::ValidationError, 'Missing required parameters: rental-location-id')
      end

      it 'raises ValidationError for multiple missing parameters' do
        params = {}
        
        expect {
          described_class.validate_required_params(params, 'rental-location-id', 'rate-type-id')
        }.to raise_error(Utils::ValidationError, 'Missing required parameters: rental-location-id, rate-type-id')
      end

      it 'raises ValidationError for empty string' do
        params = { 'rental-location-id' => '' }
        
        expect {
          described_class.validate_required_params(params, 'rental-location-id')
        }.to raise_error(Utils::ValidationError, 'Missing required parameters: rental-location-id')
      end

      it 'raises ValidationError for whitespace-only string' do
        params = { 'rental-location-id' => '   ' }
        
        expect {
          described_class.validate_required_params(params, 'rental-location-id')
        }.to raise_error(Utils::ValidationError, 'Missing required parameters: rental-location-id')
      end

      it 'raises ValidationError for nil value' do
        params = { 'rental-location-id' => nil }
        
        expect {
          described_class.validate_required_params(params, 'rental-location-id')
        }.to raise_error(Utils::ValidationError, 'Missing required parameters: rental-location-id')
      end
    end
  end

  describe '.validate_integer_params' do
    context 'with valid integer parameters' do
      it 'passes validation for numeric strings' do
        params = { 'rental-location-id' => '123' }
        
        expect {
          described_class.validate_integer_params(params, 'rental-location-id')
        }.not_to raise_error
      end

      it 'passes validation for zero' do
        params = { 'rental-location-id' => '0' }
        
        expect {
          described_class.validate_integer_params(params, 'rental-location-id')
        }.not_to raise_error
      end

      it 'passes validation for multiple valid parameters' do
        params = { 
          'rental-location-id' => '1',
          'rate-type-id' => '2'
        }
        
        expect {
          described_class.validate_integer_params(params, 'rental-location-id', 'rate-type-id')
        }.not_to raise_error
      end
    end

    context 'with invalid integer parameters' do
      it 'raises ValidationError for non-numeric string' do
        params = { 'rental-location-id' => 'abc' }
        
        expect {
          described_class.validate_integer_params(params, 'rental-location-id')
        }.to raise_error(Utils::ValidationError, 'Invalid integer parameters: rental-location-id')
      end

      it 'raises ValidationError for mixed alphanumeric string' do
        params = { 'rental-location-id' => '123abc' }
        
        expect {
          described_class.validate_integer_params(params, 'rental-location-id')
        }.to raise_error(Utils::ValidationError, 'Invalid integer parameters: rental-location-id')
      end

      it 'raises ValidationError for negative number' do
        params = { 'rental-location-id' => '-1' }
        
        expect {
          described_class.validate_integer_params(params, 'rental-location-id')
        }.to raise_error(Utils::ValidationError, 'Invalid integer parameters: rental-location-id')
      end

      it 'raises ValidationError for decimal number' do
        params = { 'rental-location-id' => '1.5' }
        
        expect {
          described_class.validate_integer_params(params, 'rental-location-id')
        }.to raise_error(Utils::ValidationError, 'Invalid integer parameters: rental-location-id')
      end

      it 'raises ValidationError for multiple invalid parameters' do
        params = { 
          'rental-location-id' => 'abc',
          'rate-type-id' => 'def'
        }
        
        expect {
          described_class.validate_integer_params(params, 'rental-location-id', 'rate-type-id')
        }.to raise_error(Utils::ValidationError, 'Invalid integer parameters: rental-location-id, rate-type-id')
      end
    end
  end

  describe '.validate_unit_id' do
    context 'with valid unit-id values' do
      it 'passes validation for unit-id = 1' do
        params = { 'unit-id' => '1' }
        
        expect {
          described_class.validate_unit_id(params, 'unit-id')
        }.not_to raise_error
      end

      it 'passes validation for unit-id = 2' do
        params = { 'unit-id' => '2' }
        
        expect {
          described_class.validate_unit_id(params, 'unit-id')
        }.not_to raise_error
      end

      it 'passes validation for unit-id = 3' do
        params = { 'unit-id' => '3' }
        
        expect {
          described_class.validate_unit_id(params, 'unit-id')
        }.not_to raise_error
      end

      it 'passes validation for unit-id = 4' do
        params = { 'unit-id' => '4' }
        
        expect {
          described_class.validate_unit_id(params, 'unit-id')
        }.not_to raise_error
      end
    end

    context 'with invalid unit-id values' do
      it 'raises ValidationError for unit-id < 1' do
        params = { 'unit-id' => '0' }
        
        expect {
          described_class.validate_unit_id(params, 'unit-id')
        }.to raise_error(Utils::ValidationError, 'Unit ID must be between 1 and 4')
      end

      it 'raises ValidationError for unit-id > 4' do
        params = { 'unit-id' => '5' }
        
        expect {
          described_class.validate_unit_id(params, 'unit-id')
        }.to raise_error(Utils::ValidationError, 'Unit ID must be between 1 and 4')
      end

      it 'raises ValidationError for non-numeric unit-id' do
        params = { 'unit-id' => 'abc' }
        
        expect {
          described_class.validate_unit_id(params, 'unit-id')
        }.to raise_error(Utils::ValidationError, 'Unit ID must be between 1 and 4')
      end
    end
  end
end

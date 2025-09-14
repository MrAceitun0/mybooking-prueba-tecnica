Parameter Tests:
bundle exec rspec spec/unit/utils/parameter_validator_spec.rb --format documentation




# ParameterValidator Unit Testing Guide

## Overview

This guide covers the comprehensive unit tests for the `Utils::ParameterValidator` class. The tests ensure that all parameter validation methods work correctly with proper error handling and edge case coverage.

## Test Structure

### Test File Location
- **Main Test File**: `spec/unit/utils/parameter_validator_spec.rb`
- **Test Runner**: `run_parameter_validator_tests.rb`
- **Rake Task**: `rake test:parameter_validator`

### Test Categories

#### 1. **`.validate_pricing_params` (Main Method)**
- ✅ **Success Cases**: Valid parameters pass validation
- ❌ **Missing Parameters**: Raises ValidationError for missing required parameters
- ❌ **Invalid Integers**: Raises ValidationError for non-integer values
- ❌ **Invalid Unit ID**: Raises ValidationError for unit-id outside range (1-4)
- 🔍 **Edge Cases**: Handles various data types and edge conditions

#### 2. **`.validate_required_params`**
- ✅ **Success Cases**: Present parameters pass validation
- ❌ **Missing Parameters**: Raises ValidationError for missing parameters
- ❌ **Empty Values**: Raises ValidationError for empty strings and whitespace
- ❌ **Nil Values**: Raises ValidationError for nil parameters
- 🔍 **Edge Cases**: Handles zero, false, and empty arrays as valid values

#### 3. **`.validate_integer_params`**
- ✅ **Success Cases**: Valid integer strings pass validation
- ❌ **Invalid Formats**: Raises ValidationError for non-numeric strings
- ❌ **Negative Numbers**: Raises ValidationError for negative values
- ❌ **Decimals**: Raises ValidationError for decimal numbers
- 🔍 **Edge Cases**: Handles nil and empty values (not validated)

#### 4. **`.validate_unit_id`**
- ✅ **Success Cases**: Unit IDs 1-4 pass validation
- ❌ **Out of Range**: Raises ValidationError for values outside 1-4 range
- ❌ **Invalid Types**: Raises ValidationError for non-numeric values
- 🔍 **Edge Cases**: Handles nil, empty strings, and boolean values

## Test Coverage

### Parameter Validation Scenarios

#### **Required Parameter Validation**
```ruby
# Success cases
params = { 'rental-location-id' => '1' }
validate_required_params(params, 'rental-location-id') # ✅ Passes

# Failure cases
params = {}
validate_required_params(params, 'rental-location-id') # ❌ Missing parameter

params = { 'rental-location-id' => '' }
validate_required_params(params, 'rental-location-id') # ❌ Empty string

params = { 'rental-location-id' => '   ' }
validate_required_params(params, 'rental-location-id') # ❌ Whitespace only

params = { 'rental-location-id' => nil }
validate_required_params(params, 'rental-location-id') # ❌ Nil value
```

#### **Integer Parameter Validation**
```ruby
# Success cases
params = { 'rental-location-id' => '123' }
validate_integer_params(params, 'rental-location-id') # ✅ Valid integer

params = { 'rental-location-id' => '0' }
validate_integer_params(params, 'rental-location-id') # ✅ Zero is valid

# Failure cases
params = { 'rental-location-id' => 'abc' }
validate_integer_params(params, 'rental-location-id') # ❌ Non-numeric

params = { 'rental-location-id' => '-1' }
validate_integer_params(params, 'rental-location-id') # ❌ Negative number

params = { 'rental-location-id' => '1.5' }
validate_integer_params(params, 'rental-location-id') # ❌ Decimal number
```

#### **Unit ID Validation**
```ruby
# Success cases
params = { 'unit-id' => '1' }
validate_unit_id(params, 'unit-id') # ✅ Valid range (1-4)

params = { 'unit-id' => '4' }
validate_unit_id(params, 'unit-id') # ✅ Valid range (1-4)

# Failure cases
params = { 'unit-id' => '0' }
validate_unit_id(params, 'unit-id') # ❌ Below range

params = { 'unit-id' => '5' }
validate_unit_id(params, 'unit-id') # ❌ Above range

params = { 'unit-id' => 'abc' }
validate_unit_id(params, 'unit-id') # ❌ Non-numeric
```

### Error Message Validation

#### **Single Parameter Errors**
```ruby
# Missing parameter
expect {
  validate_required_params({}, 'rental-location-id')
}.to raise_error(Utils::ValidationError, 'Missing required parameters: rental-location-id')

# Invalid integer
expect {
  validate_integer_params({ 'rental-location-id' => 'abc' }, 'rental-location-id')
}.to raise_error(Utils::ValidationError, 'Invalid integer parameters: rental-location-id')
```

#### **Multiple Parameter Errors**
```ruby
# Multiple missing parameters
expect {
  validate_required_params({}, 'rental-location-id', 'rate-type-id')
}.to raise_error(Utils::ValidationError, 'Missing required parameters: rental-location-id, rate-type-id')

# Multiple invalid integers
expect {
  validate_integer_params({ 
    'rental-location-id' => 'abc',
    'rate-type-id' => 'def'
  }, 'rental-location-id', 'rate-type-id')
}.to raise_error(Utils::ValidationError, 'Invalid integer parameters: rental-location-id, rate-type-id')
```

## Running the Tests

### Option 1: Using Rake Tasks
```bash
# Run parameter validator tests only
rake test:parameter_validator

# Run all unit tests
rake test:unit
```

### Option 2: Using the Test Runner Script
```bash
ruby run_parameter_validator_tests.rb
```

### Option 3: Using RSpec Directly
```bash
# Run parameter validator tests
bundle exec rspec spec/unit/utils/parameter_validator_spec.rb

# Run with documentation format
bundle exec rspec spec/unit/utils/parameter_validator_spec.rb --format documentation

# Run specific test
bundle exec rspec spec/unit/utils/parameter_validator_spec.rb:45
```

## Test Assertions

### Success Case Assertions
```ruby
it 'passes validation for valid parameters' do
  params = { 'rental-location-id' => '1' }
  
  expect {
    described_class.validate_pricing_params(params, 'rental-location-id')
  }.not_to raise_error
end
```

### Error Case Assertions
```ruby
it 'raises ValidationError for missing parameter' do
  params = {}
  
  expect {
    described_class.validate_required_params(params, 'rental-location-id')
  }.to raise_error(Utils::ValidationError, 'Missing required parameters: rental-location-id')
end
```

### Exception Type Assertions
```ruby
it 'raises Utils::ValidationError' do
  params = { 'rental-location-id' => 'abc' }
  
  expect {
    described_class.validate_integer_params(params, 'rental-location-id')
  }.to raise_error(Utils::ValidationError)
end
```

## Test Data Examples

### Valid Test Data
```ruby
# Valid parameters for pricing API
valid_params = {
  'rental-location-id' => '1',
  'rate-type-id' => '2',
  'season-definition-id' => '3',
  'season-id' => '4',
  'unit-id' => '2'
}

# Valid unit IDs
valid_unit_ids = ['1', '2', '3', '4']

# Valid integer strings
valid_integers = ['0', '1', '123', '999999']
```

### Invalid Test Data
```ruby
# Invalid parameters
invalid_params = {
  'rental-location-id' => 'abc',      # Non-numeric
  'rate-type-id' => '-1',            # Negative
  'unit-id' => '5',                  # Out of range
  'season-id' => '1.5'               # Decimal
}

# Invalid unit IDs
invalid_unit_ids = ['0', '5', '-1', 'abc', '2.5']

# Invalid integer strings
invalid_integers = ['abc', '123abc', '-1', '1.5', 'true', '[]']
```

## Edge Cases Covered

### Data Type Edge Cases
- **Nil Values**: Handled appropriately for each validation type
- **Empty Strings**: Treated as missing for required params, ignored for integer validation
- **Whitespace Strings**: Treated as missing for required params
- **Boolean Values**: Treated as invalid for integer validation
- **Array/Hash Values**: Treated as invalid for integer validation
- **Zero Values**: Valid for integers, invalid for unit-id

### Boundary Conditions
- **Unit ID Range**: Tests values 0, 1, 4, 5 (boundaries and beyond)
- **Large Numbers**: Tests with very large integer strings
- **Leading Zeros**: Tests with strings like "01" (valid)
- **Negative Numbers**: Tests with negative integer strings

### Multiple Parameter Scenarios
- **Mixed Valid/Invalid**: Tests combinations of valid and invalid parameters
- **All Invalid**: Tests when all parameters are invalid
- **All Valid**: Tests when all parameters are valid
- **Partial Missing**: Tests when some required parameters are missing

## Best Practices Demonstrated

### 1. **Descriptive Test Names**
```ruby
it 'raises ValidationError for unit-id below range' do
  # Test implementation
end

it 'passes validation for multiple present parameters' do
  # Test implementation
end
```

### 2. **Comprehensive Coverage**
- Tests both success and failure scenarios
- Tests edge cases and boundary conditions
- Tests all parameter combinations

### 3. **Clear Assertions**
```ruby
# Specific error message validation
expect {
  # method call
}.to raise_error(Utils::ValidationError, 'Expected error message')

# Exception type validation
expect {
  # method call
}.to raise_error(Utils::ValidationError)
```

### 4. **Organized Test Structure**
```ruby
describe '.validate_pricing_params' do
  context 'with valid parameters' do
    # Success cases
  end

  context 'with missing required parameters' do
    # Missing parameter cases
  end

  context 'with invalid integer parameters' do
    # Invalid integer cases
  end
end
```

## Troubleshooting

### Common Issues

#### 1. **Test Database Setup**
```ruby
# Unit tests use in-memory database
# No special setup required for ParameterValidator tests
```

#### 2. **Exception Handling**
```ruby
# Ensure Utils::ValidationError is properly required
require_relative '../../app/utils/custom_errors'
```

#### 3. **Test Data Setup**
```ruby
# Use simple hash structures for parameter testing
params = { 'key' => 'value' }
```

### Debug Tips

#### 1. **Verbose Output**
```bash
bundle exec rspec spec/unit/utils/parameter_validator_spec.rb --format documentation
```

#### 2. **Single Test Execution**
```bash
bundle exec rspec spec/unit/utils/parameter_validator_spec.rb:45
```

#### 3. **Test Data Inspection**
```ruby
# Add debug output in tests
puts "Testing with params: #{params.inspect}"
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: ParameterValidator Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.0
      - name: Install dependencies
        run: bundle install
      - name: Run ParameterValidator tests
        run: rake test:parameter_validator
```

## Conclusion

These unit tests provide comprehensive coverage of the ParameterValidator class, ensuring:
- ✅ **Functionality**: All validation methods work as expected
- ✅ **Error Handling**: Proper ValidationError exceptions are raised
- ✅ **Edge Cases**: Boundary conditions and unusual inputs are handled
- ✅ **Message Formatting**: Error messages are properly formatted
- ✅ **Integration**: Methods work together correctly in validate_pricing_params

The tests serve as both validation and documentation of the parameter validation behavior, making it easier to maintain and extend the validation logic.

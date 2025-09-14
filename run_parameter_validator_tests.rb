#!/usr/bin/env ruby

# Simple script to run unit tests for the ParameterValidator class
# Usage: ruby run_parameter_validator_tests.rb

require 'bundler/setup'
require 'rspec'

# Configure RSpec
RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
end

# Run the parameter validator tests
puts "Running ParameterValidator Unit Tests..."
puts "=" * 50

# Run only the parameter validator tests
RSpec::Core::Runner.run(['spec/unit/utils/parameter_validator_spec.rb'])

puts "=" * 50
puts "ParameterValidator tests completed!"

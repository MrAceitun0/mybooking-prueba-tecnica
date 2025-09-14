require_relative '../config/application'

require 'timecop'
require 'rspec/its'
require 'factory_bot' # Include factory bot
require 'database_cleaner' # Use instead of database_cleaner-data_mapper
require 'webmock/rspec' # Include webmock for HTTP stubs

# Allow sqlite transaction save point
module DataMapper
  class Transaction
  	module SqliteAdapter
      def supports_savepoints?
        true
      end
  	end
  end
end

# Configure FactoryBot
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do

    is_unit_test = RSpec.configuration.files_to_run.any? do |file|
      file.include?('/unit/') || file.include?('/e2e/') || RSpec.configuration.filter[:unit]
    end

    # Unit testing use in-memory database => auto_migrate! for datamapper
    if is_unit_test
      database_url = 'sqlite::memory:'
    else
      database_url = ENV['TEST_DATABASE_URL']
    end

    # Setup DataMapper
    DataMapper.setup(:default, database_url)
    DataMapper::Model.raise_on_save_failure = true
    DataMapper.finalize

    # Unit testing use in-memory database => auto_migrate! for datamapper
    if is_unit_test
      DataMapper.auto_migrate!
    end

    DatabaseCleaner.allow_remote_database_url = true

    # To load factories
    FactoryBot.definition_file_paths = [File.expand_path('../factories', __FILE__)]
    FactoryBot.find_definitions
    # To clear database between tests
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, {except: %w[schema_migrations]})
  end

  # To clear database between tests
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  #config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# 2024-06-08 : Define the custom strategy for associactions => :first_or_create
class FindOrCreateForDataMapper
  def initialize
    @default_strategy = FactoryBot::Strategy::Create.new
  end

  def association(runner)
    runner.run
  end

  # Return the strategy name as a symbol
  def to_sym
    :find_or_create
  end

  # Run the strategy
  def result(evaluation)

    # Search for an existing object by primary key
    instance = evaluation.object

    # Build the PK as a Hash
    model_class = instance.class
    primary_keys = model_class.key.map(&:name).map(&:to_sym)
    pk = primary_keys.inject({}) do |result, item|
      result[item] = instance.attributes[item]
      result
    end

    # Use DataMapper model class to run a first search
    existing_instance = model_class.first(pk)

    # Si se encuentra un registro existente, devuélvelo
    return existing_instance if existing_instance

    # Si no se encuentra un registro existente, utiliza la estrategia de creación predeterminada
    @default_strategy.result(evaluation)
  end
end

# Registra la estrategia personalizada para find_or_create
FactoryBot.register_strategy(:find_or_create, FindOrCreateForDataMapper)

# Setup DataMapper for FactoryBot
class CreateForDataMapper
  def initialize
    @default_strategy = FactoryBot::Strategy::Create.new
  end

  delegate :association, to: :@default_strategy

  # From Version 6.2.1 https://github.com/thoughtbot/factory_bot/issues/1536
  # BREAKING CHANGE: Custom strategies now need to define a to_sym method to specify the strategy identifier
  # It is the same name as registered strategy
  def to_sym
    :create
  end

  # https://stackoverflow.com/questions/15180951/why-is-before-save-callback-hook-not-getting-called-from-factorygirl-create
  def result(evaluation)
    evaluation.singleton_class.send :define_method, :create do |instance|
      if !instance.save
        message = "Save failed for #{instance.class.name} #{instance.valid?} #{instance.errors.inspect}"
        raise Exception.new(message)
      end
    end

    @default_strategy.result(evaluation)
  end
end

FactoryBot.register_strategy(:create, CreateForDataMapper)

require 'rake'

require_relative 'config/application'

task :basic_environment do
  desc "Basic environment"
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

namespace :import do
  desc "Import prices from CSV file"
  task :prices, [:file_path] => :basic_environment do |t, args|
    if args[:file_path].nil?
      puts "Usage: rake import:prices[path/to/file.csv]"
      exit 1
    end

    file_path = args[:file_path]
    
    unless File.exist?(file_path)
      puts "Error: File '#{file_path}' not found"
      exit 1
    end

    puts "Starting price import from: #{file_path}"
    puts "=" * 50

    import_service = Service::ImportPricesService.new
    success = import_service.import_from_file(file_path)

    puts "\nImport Results:"
    puts "-" * 20
    puts "Imported: #{import_service.imported_count} prices"
    puts "Updated:  #{import_service.updated_count} prices"
    puts "Skipped:  #{import_service.skipped_count} prices"
    
    if import_service.errors.any?
      puts "\nErrors encountered:"
      puts "-" * 20
      import_service.errors.each do |error|
        puts "❌ #{error}"
      end
      puts "\nImport completed with errors."
      exit 1
    else
      puts "\n✅ Import completed successfully!"
    end
  end
end

namespace :test do
  desc "Run unit tests for ParameterValidator"
  task :parameter_validator => :basic_environment do
    puts "Running ParameterValidator Unit Tests..."
    puts "=" * 50
    
    # Run the parameter validator tests
    system("bundle exec rspec spec/unit/utils/parameter_validator_spec.rb --format documentation")
    
    puts "=" * 50
    puts "ParameterValidator tests completed!"
  end

  desc "Run all unit tests"
  task :unit => :basic_environment do
    puts "Running All Unit Tests..."
    puts "=" * 50
    
    # Run all unit tests
    system("bundle exec rspec spec/unit/ --format documentation")
    
    puts "=" * 50
    puts "Unit tests completed!"
  end
end

namespace :foo do
  desc "Foo task"
  task :bar do
    puts "Foo bar"
  end
end

module Utils
  module ParameterValidator
    class << self

      def validate_pricing_params(params, *required_params)
        validate_required_params(params, *required_params)
        validate_integer_params(params, *required_params)
        validate_unit_id(params, *required_params)
      end

      def validate_required_params(params, *required_params)
        missing_params = []
        required_params.each do |param|
          value = params[param]
          if value.nil? || value.to_s.strip.empty?
            missing_params << param
          end
        end
        
        unless missing_params.empty?
          raise Utils::ValidationError.new("Missing required parameters: #{missing_params.join(', ')}")
        end
      end

      def validate_integer_params(params, *integer_params)
        invalid_params = []
        integer_params.each do |param|
          value = params[param]
          if value && !value.to_s.match?(/^\d+$/)
            invalid_params << param
          end
        end
        
        unless invalid_params.empty?
          raise Utils::ValidationError.new("Invalid integer parameters: #{invalid_params.join(', ')}")
        end
      end

      def validate_unit_id(params, *unit_id_params)
        if unit_id_params.include?('unit-id')
          unit_id = params['unit-id'].to_i
          unless (1..4).include?(unit_id)
            raise Utils::ValidationError.new("Unit ID must be between 1 and 4")
          end
        end
      end

    end
  end
end
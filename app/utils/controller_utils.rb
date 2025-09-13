module Utils
    module ControllerUtils
      class << self
        
        def validate_required_params(params, *required_params)
          required_params.each do |param|
            value = params[param]
            if value.nil? || value.to_s.strip.empty?
              Utils::ErrorHandler.handle_parameter_error(param)
            end
          end
        end
  
        def validate_integer_params(params, *integer_params)
          integer_params.each do |param|
            value = params[param]
            if value && !value.to_s.match?(/^\d+$/)
              Utils::ErrorHandler.handle_parameter_error(param, "The '#{param}' parameter must be a valid integer.")
            end
          end
        end
  
        def safe_execute(operation_description, &block)
          begin
            yield
          rescue => e
            Utils::ErrorHandler.handle_application_error(operation_description, e)
          end
        end
  
        def set_json_content_type
          content_type :json
        end
  
        def json_response(data)
          set_json_content_type
          data.to_json
        end
      end
    end
  end
  
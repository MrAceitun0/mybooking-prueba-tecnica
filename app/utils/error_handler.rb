module Utils
    module ErrorHandler
      class << self
  
          def handle_parameter_error(param_name, message = nil)
          error_message = message || "The '#{param_name}' parameter is required."
          halt 400, { message: error_message }.to_json
        end
  
        def handle_not_found_error(resource, identifier = nil)
          error_message = if identifier
            "#{resource} '#{identifier}' not found."
          else
            "#{resource} not found."
          end
          halt 404, { message: error_message }.to_json
        end
  
        def handle_empty_results(resource, context = nil)
          error_message = if context
            "No #{resource} found for #{context}."
          else
            "No #{resource} found for your conditions."
          end
          halt 404, { message: error_message }.to_json
        end
  
        def handle_general_error(message, status_code = 500)
          halt status_code, { message: message }.to_json
        end
  
        def handle_application_error(operation, error)
          error_message = "Error al #{operation}: #{error.message}"
          halt 500, { message: error_message }.to_json
        end
      end
    end
  end
  
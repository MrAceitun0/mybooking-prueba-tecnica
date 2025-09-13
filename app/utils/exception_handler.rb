module Utils
  module ExceptionHandler
    def self.included(app)
      # Disable Sinatra's default exception handling
      app.set :show_exceptions, false
      
      # Handle our custom exceptions
      app.error Utils::ValidationError do |e|
        content_type :json
        halt e.status, { 
          error: {
            code: e.code,
            message: e.message,
            timestamp: Time.now.iso8601
          }
        }.to_json
      end

      app.error Utils::NotFoundError do |e|
        content_type :json
        halt e.status, { 
          error: {
            code: e.code,
            message: e.message,
            timestamp: Time.now.iso8601
          }
        }.to_json
      end

      app.error Utils::DatabaseError do |e|
        content_type :json
        halt e.status, { 
          error: {
            code: e.code,
            message: e.message,
            timestamp: Time.now.iso8601
          }
        }.to_json
      end

      app.error Utils::BusinessLogicError do |e|
        content_type :json
        halt e.status, { 
          error: {
            code: e.code,
            message: e.message,
            timestamp: Time.now.iso8601
          }
        }.to_json
      end

      app.error Utils::UnauthorizedError do |e|
        content_type :json
        halt e.status, { 
          error: {
            code: e.code,
            message: e.message,
            timestamp: Time.now.iso8601
          }
        }.to_json
      end

      app.error Utils::ForbiddenError do |e|
        content_type :json
        halt e.status, { 
          error: {
            code: e.code,
            message: e.message,
            timestamp: Time.now.iso8601
          }
        }.to_json
      end

      app.error Utils::ConflictError do |e|
        content_type :json
        halt e.status, { 
          error: {
            code: e.code,
            message: e.message,
            timestamp: Time.now.iso8601
          }
        }.to_json
      end

      # Handle all other ApplicationError subclasses
      app.error Utils::ApplicationError do |e|
        content_type :json
        halt e.status, { 
          error: {
            code: e.code,
            message: e.message,
            timestamp: Time.now.iso8601
          }
        }.to_json
      end

      # Handle unexpected errors
      app.error StandardError do |e|
        content_type :json
        halt 500, { 
          error: {
            code: 'UNEXPECTED_ERROR',
            message: "An unexpected error occurred: #{e.message}",
            timestamp: Time.now.iso8601
          }
        }.to_json
      end
    end
  end
end

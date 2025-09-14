module Utils
  module ExceptionHandler
    def self.included(app)
      app.set :show_exceptions, false
      
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

module Utils
  # Base exception class for all application errors
  class ApplicationError < StandardError
    attr_reader :status, :code
    
    def initialize(message, status = 500, code = 'INTERNAL_SERVER_ERROR')
      super(message)
      @status = status
      @code = code
    end
  end

  class ValidationError < ApplicationError
    def initialize(message, field = nil)
      super(message, 400, 'VALIDATION_ERROR')
      @field = field
    end
  end

  class NotFoundError < ApplicationError
    def initialize(resource, identifier = nil)
      message = if identifier
        "#{resource.capitalize} '#{identifier}' not found."
      else
        "#{resource.capitalize} not found."
      end
      super(message, 404, 'NOT_FOUND')
    end
  end

  class DatabaseError < ApplicationError
    def initialize(message)
      super(message, 500, 'DATABASE_ERROR')
    end
  end
end
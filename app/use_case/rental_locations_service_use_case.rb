module UseCase
  class RentalLocationsServiceUseCase

    Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)


    def initialize(rental_location_service, logger)
      @rental_location_service = rental_location_service
      @logger = logger
    end


    def perform()
      data = self.load_data
      @logger.debug "RentalLocationServiceUseCase - execute - data: #{data.inspect}"

      return Result.new(success?: true, authorized?: true, data: data)

    end

    private

    def load_data
      @rental_location_service.retrieve

    end
  end
end

module UseCase
  class RentalLocationsServiceUseCase

    Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

    def initialize(rental_locations_service, logger)
      @rental_locations_service = rental_locations_service
      @logger = logger
    end


    def perform()
      return Result.new(success?: true, authorized?: true, data: self.load_data)
    end

    private

    def load_data
      @rental_locations_service.retrieve
    end
  end
end

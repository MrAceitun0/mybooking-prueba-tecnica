module UseCase
  class RateTypesServiceUseCase

    Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)


    def initialize(rate_types_service, logger)
      @rate_types_service = rate_types_service
      @logger = logger
    end


    def perform()
      return Result.new(success?: true, authorized?: true, data: self.load_data)
    end

    private

    def load_data()
      @rate_types_service.retrieve
    end
  end
end

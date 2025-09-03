module UseCase
  class SeasonsServiceUseCase

    Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)


    def initialize(seasons_service, logger)
      @seasons_service = seasons_service
      @logger = logger
    end


    def perform()
      data = self.load_data
      return Result.new(success?: true, authorized?: true, data: data)

    end

    private

    def load_data
      @seasons_service.retrieve
    end
  end
end

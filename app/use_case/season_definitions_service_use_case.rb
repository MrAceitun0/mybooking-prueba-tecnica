module UseCase
  class SeasonDefinitionsServiceUseCase

    Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

    def initialize(season_definitions_service, logger)
      @season_definitions_service = season_definitions_service
      @logger = logger
    end


    def perform()
      return Result.new(success?: true, authorized?: true, data: self.load_data())
    end

    private

    def load_data()
      @season_definitions_service.retrieve
    end
  end
end

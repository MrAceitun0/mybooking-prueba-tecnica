module Controller
  module Api
    module PricingController

      def self.registered(app)

        app.get '/api/rental-locations' do

          service = Service::ListRentalLocationsService.new
          use_case = UseCase::RentalLocationsServiceUseCase.new(service, logger)
          result = use_case.perform()

          if result.success?
            content_type :json
            result.data.to_json
          elsif !result.authorized?
            halt 401
          else
            halt 400, result.message.to_json
          end
        end

        app.get '/api/rate-types' do

          service = Service::ListRateTypesService.new
          use_case = UseCase::RateTypesServiceUseCase.new(service, logger)
          result = use_case.perform()

          if result.success?
            content_type :json
            result.data.to_json
          elsif !result.authorized?
            halt 401
          else
            halt 400, result.message.to_json
          end
        end

        app.get '/api/season-definitions' do

          service = Service::ListSeasonDefinitionsService.new
          use_case = UseCase::SeasonDefinitionsServiceUseCase.new(service, logger)
          result = use_case.perform()

          if result.success?
            content_type :json
            result.data.to_json
          elsif !result.authorized?
            halt 401
          else
            halt 400, result.message.to_json
          end
        end

        app.get '/api/seasons' do

          service = Service::ListSeasonsService.new
          use_case = UseCase::SeasonsServiceUseCase.new(service, logger)
          result = use_case.perform()

          if result.success?
            content_type :json
            result.data.to_json
          elsif !result.authorized?
            halt 401
          else
            halt 400, result.message.to_json
          end
        end

      end
    end
  end
end

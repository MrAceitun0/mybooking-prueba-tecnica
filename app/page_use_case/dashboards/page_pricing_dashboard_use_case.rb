module PageUseCase
    module Dashboards
      class PagePricingDashboardUseCase
  
        Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)
  
        def initialize(logger)
          @logger = logger
        end
  
        def perform(params)
  
          processed_params = process_params(params)
  
          unless processed_params[:valid]
            return Result.new(success?: false, authorized?: true, message: processed_params[:message])
          end
  
          unless processed_params[:authorized]
            return Result.new(success?: true, authorized?: false, message: 'Not authorized')
          end
          
          return Result.new(success?: true, authorized?: true, data: "Hola Mundo!")
          
        end
  
        private
  
        def process_params(params)
  
          return { valid: true, authorized: true }
  
        end
  
      end
    end
  end
  
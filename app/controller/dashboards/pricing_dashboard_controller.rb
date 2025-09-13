module Controller
    module Dashboards
      module PricingDashboardController
  
        def self.registered(app)
          app.get '/pricing' do
  
            use_case = PageUseCase::Dashboards::PagePricingDashboardUseCase.new(logger)
            result = use_case.perform(params)
  
            @title = "Listado de Tarifas"
  
            if result.success?
              erb :pricing_dashboard
            else
              @message = result.message
              erb :error_page
            end
  
          end
  
        end
      end
    end
  end
  
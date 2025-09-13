require_relative 'lib/autoregister'
require_relative 'app/utils/custom_errors'
require_relative 'app/utils/exception_handler'

module Sinatra
  class Application < Sinatra::Base

    include Utils::ExceptionHandler

    configure do
      set :root, File.expand_path('..', __FILE__)
      set :views, File.join(root, 'app/views')
      set :public_folder, File.join(root, 'app/assets')
    end

    register Sinatra::AutoRegister

  end
end

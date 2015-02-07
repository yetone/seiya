require 'seiya/middleware'
require 'seiya/settings'

module Seiya
  module Contrib
    module RequestMiddlewares
      class RandomUserAgentMiddleware < Seiya::RequestMiddleware
        def process_request(request)
          headers = request.headers
          headers = {} unless headers.is_a? Hash
          headers['User-Agent'] = Seiya::Settings::USER_AGENTS.sample
        end
      end
    end
  end
end
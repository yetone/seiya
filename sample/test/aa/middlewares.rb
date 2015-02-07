require 'paint'
require 'seiya'

module RequestMiddlewares
  class MyMiddleware < Seiya::RequestMiddleware
    def process_request(request)
      puts Paint['I am MyMiddleware!', :red]
      puts Paint["User-Agent: #{request.headers['User-Agent']}", :random]
    end
  end
  class MySubMiddleware < Seiya::RequestMiddleware
    def process_request(request)
      puts Paint['I am MySubMiddleware!', :green]
    end
  end
end

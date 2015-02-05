require 'httpclient'
require 'nokogiri'
require 'singleton'
require 'seiya/response'

module Seiya
  class Request
    def initialize(url, *args, method: 'get')
      @url = url
      @method = method.upcase
      @args = args
      @httpclient = HTTPClient.new
    end

    def get_response
      Response.new @httpclient.send(@method.downcase, @url, *@args)
    end

    def register(&block)
      @handler = proc do
        Enumerator.new do |enum|
          block.call(get_response, enum)
        end
      end
    end

    def registered?
      !@handler.nil?
    end

    def fire
      @handler.call
    end
  end
end
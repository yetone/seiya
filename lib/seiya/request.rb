require 'httpclient'
require 'nokogiri'
require 'singleton'
require 'seiya/response'

module Seiya
  class Request
    attr_reader :url
    attr_accessor :params, :headers

    def initialize(url, *args, params: {}, headers: {}, method: 'get')
      @url = url
      @method = method.upcase
      @args = args
      @params = params
      @headers = headers
      @httpclient = HTTPClient.new
    end

    def get_response
      Response.new @httpclient.send(@method.downcase, @url, @params, @headers, *@args)
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
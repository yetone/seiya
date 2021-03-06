require 'seiya/request'
require 'seiya/item'
require 'seiya/pipeline'
require 'seiya/util'
require 'seiya/scheduler'

def process_gen(gen)
  gen.each do |e|
    if e.is_a? Seiya::Item
      Seiya.process_item e
    elsif e.is_a? Enumerator
      process_gen e
    end
  end
end


module Seiya
  class Task
    def initialize
      @start_urls = []
    end

    def self.summary
      'I am a seiya task'
    end

    def run
      return unless @start_urls.is_a? Array
      handler = method :parse
      requests = @start_urls.map do |url|
        request = Request.new url
        request.register &handler
        request
      end
      Scheduler.instance.add_requests requests
    end
  end
end
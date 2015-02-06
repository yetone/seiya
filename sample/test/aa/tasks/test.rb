require 'seiya'
require_relative '../items'

module Tasks
  class Test < Seiya::Task
    def initialize *args
      puts args
      @start_urls = ('a'..'d').map do |w|
        'http://www.baidu.com/?key=' << w
      end
    end
    
    def parse(response, enum)
      item = Items::Test.new
      item[:url] = response.url
      enum.yield item
      request = Seiya::Request.new 'http://www.weibo.com'
      request.register &method(:other_parse)
      enum.yield request
    end

    def other_parse(response, enum)
      item = Items::Test.new name: 'yetone', url: response.url
      enum.yield item
    end
  end
end

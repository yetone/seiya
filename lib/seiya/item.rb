require 'json'

module Seiya
  class Item
    def initialize(data = {})
      @data = {}
      @data.merge!(data)
    end

    def load(json_str)
      @data.merge!(JSON.parse json_str)
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end

    def inspect
      @data.inspect
    end

    def to_h
      @data
    end

    def to_json
      @data.to_json
    end
  end
end
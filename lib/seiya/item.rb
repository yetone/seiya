module Seiya
  class Item
    def initialize(h = {})
      @data = {}
      @data.merge!(h)
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
  end
end
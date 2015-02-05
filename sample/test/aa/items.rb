require 'seiya'

module Items
  class Test < Seiya::Item
    def to_s
      'I am a Test item'
    end
  end
end
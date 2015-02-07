require 'paint'
require 'seiya'

module Pipelines
  class A < Seiya::Pipeline
    def process_item(item)
      puts Paint['I am A Pipeline', :yellow]
      item[:pipeline] = 'A'
      item
    end
  end
  class B < Seiya::Pipeline
    def process_item(item)
      puts Paint['I am B Pipeline', :blue]
      puts item.to_json
      item
    end
  end
end
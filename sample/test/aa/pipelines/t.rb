require 'seiya'

module Pipelines
  class A < Seiya::Pipeline
    def process_item(item)
      p 'I am A Pipeline'
      item[:pipeline] = 'A'
      item
    end
  end
  class B < Seiya::Pipeline
    def process_item(item)
      p 'I am B Pipeline'
      p item
      item
    end
  end
end
require 'seiya/pipeline'

module Contrib
  module Pipelines
    class BasePipeline < Seiya::Pipeline
      def process_item(item)
        item
      end
    end
  end
end

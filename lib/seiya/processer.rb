module Seiya
  def process_item(item)
    @pipelines.each do |p|
      item = p.process_item item
    end
  end

  def process_request(request)
    @request_middlewares.each do |rm|
      rm.process_request request
    end
  end
end
require 'singleton'

module Seiya
  class Scheduler
    include Singleton

    def initialize
      @request_q = Queue.new
      @run = false
    end

    def add_requests(requests)
      requests.each do |request|
        next unless request.registered?
        Seiya.process_request request
        @request_q << request
      end
      run unless @run
    end

  private

    def run
      @run = true
      @thread = Thread.new do
        requests = []
        until @request_q.empty?
          requests << @request_q.pop
        end
        multi_run requests
      end
      @thread.join
      if @request_q.empty?
        stop
      else
        run
      end
    end

    def num_processors
      return @num_processors unless @num_processors.nil?
      @num_processors = Util.num_processors
    end

    def multi_run(requests)
      count = requests.count / num_processors + 1
      threads = []
      requests.each_slice(count) do |slice|
        threads << Thread.new do
          process_requests slice
        end
      end
      threads.each do |t|
        t.join
      end
    end

    def process_requests(requests)
      requests.each do |request|
        gen = request.fire
        process_gen gen
      end
    end

    def process_gen(gen)
      gen.each do |e|
        if e.is_a? Array
          e.each do |_e|
            process_gen _e
          end
        elsif e.is_a? Seiya::Item
          Seiya.process_item e
        elsif e.is_a? Request
          add_requests [e]
        elsif e.is_a? Enumerator
          process_gen e
        end
      end
    end

    def stop
      @run = false
    end
  end
end
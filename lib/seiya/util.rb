module Seiya
  module Util
    extend self

    def get_const(str)
      str.split('::').inject(Object) do |o, c|
        o.const_get c
      end
    end

    def processors_in_use
      procs=[]
      Dir.glob('/proc/*/stat') do |filename|
        next if File.directory?(filename)
        this_proc=[]
        File.open(filename) { |file| this_proc = file.gets.split.values_at(2, 38) }
        procs << this_proc[1].to_i if this_proc[0] == 'R'
      end
      procs.uniq.length
    end

    def num_processors
      IO.readlines('/proc/cpuinfo').delete_if { |x| x.index('processor') == nil }.length
    end

    def num_free_processors
      num_processors - processors_in_use
    end

    def estimate_free_cpus(count, wait_time)
      results = []
      count.times {
        results << num_free_processors
        sleep(wait_time)
      }
      sum = 0
      results.each { |x| sum += x }
      (sum.to_f / results.length).round
    end
  end
end

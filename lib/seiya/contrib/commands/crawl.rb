require 'seiya/command'
require 'optparse'

module Contrib
  module Commands
    class Crawl < Seiya::Command
      def run(*args)
        require 'tasks'

        task_name = args.shift
        if task_name.nil?
          puts 'Need a task_name'
          exit!
        end
        task_class = Seiya.get_task_class task_name

        options = {}
        OptionParser.new do |opts|
          opts.banner = 'Usage: seiya [options]'

          opts.on '-aArg', '--argument=Arg', 'send argument to seiya task' do |a|
            options[:args] = [] unless options[:args]
            options[:args] << a
          end
        end.parse!

        _args = options[:args] ? options[:args] : []

        task = task_class.new *_args

        task.run
      end
    end
  end
end

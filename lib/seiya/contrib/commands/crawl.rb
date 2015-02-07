require 'seiya/command'
require 'optparse'

module Seiya
  module Contrib
    module Commands
      class Crawl < Seiya::Command
        def summary
          'Crawl a task'
        end

        def usage
          'Usage
=====
  seiya crawl <task_name> [options]

Run a task

Options
=======
--help, -h      show this help message and exit
-a NAME=VALUE   set task argument (may be repeated)
--list, -l      show task list in this project'
        end

        def print_task_list
          task_list = Seiya.tasks.map do |k, v|
            '%-14s%-30s' % [k, v]
          end.join("\n")
          puts "Task list
=========

#{task_list}
"
        end

        def run(*args)
          options = {}
          OptionParser.new do |opts|
            opts.banner = 'Usage: seiya [options]'

            opts.on '-aArg', '--argument=Arg', 'send argument to seiya task' do |a|
              options[:args] = [] unless options[:args]
              options[:args] << a
            end

            opts.on '-l', '--list', 'list tasks' do |l|
              options[:list] = l
            end
          end.parse!

          if options[:list]
            print_task_list
            exit 0
          end

          task_name = args.shift
          if task_name.nil?
            puts 'Need a task_name'
            exit!
          end
          task_class = Seiya.get_task_class task_name


          _args = options[:args] ? options[:args] : []

          task = task_class.new *_args

          task.run
        end
      end
    end
  end
end

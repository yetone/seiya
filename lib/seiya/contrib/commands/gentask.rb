require 'seiya/command'
module Contrib
  module Commands
    class Gentask < Seiya::Command
      def summary
        'Generate new task using pre-defined templates'
      end

      def usage
        'Usage
=====
  seiya gentask [options] <name> <domain>

Generate new task using pre-defined templates

Options
=======
--help, -h      show this help message and exit'
      end

      def run(*args)
        task_name = args.shift
        task_domain = args.shift
        if task_name.nil?
          puts 'Need a task_name!'
          exit!
        end
        Seiya.gen_task_file task_name, task_domain
      end
    end
  end
end

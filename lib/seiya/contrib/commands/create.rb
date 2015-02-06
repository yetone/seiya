require 'seiya/command'
module Contrib
  module Commands
    class Create < Seiya::Command
      def summary
        'Create a new project'
      end

      def usage
        'Usage
=====
  seiya create <project_name>

Create new project

Options
=======
--help, -h      show this help message and exit'
      end

      def run(*args)
        project_name = args.shift
        if project_name.nil?
          puts 'Need a project_name!'
          exit!
        end
        Seiya.gen_project_file project_name
      end
    end
  end
end
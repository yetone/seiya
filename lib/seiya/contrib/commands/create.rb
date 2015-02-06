require 'seiya/command'
module Contrib
  module Commands
    class Create < Seiya::Command
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
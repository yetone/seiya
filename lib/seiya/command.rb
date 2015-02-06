module Seiya
  class Command
    def summary
      'I am a seiya command'
    end

    def usage
      'no usage'
    end

    def run
    end

    def run!(*args)
      if args.include? '-h' or args.include? '--help'
        puts usage
        return
      end
      run *args
    end
  end
end
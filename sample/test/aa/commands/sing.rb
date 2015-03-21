require 'seiya'

module Commands
  class Sing < Seiya::Command
    def run
      puts 'I am a singer!'
    end
  end
end
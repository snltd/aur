# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'
require_relative '../stdlib/numeric'

module Aur
  module Command
    #
    # Ask the user for a number, then prefix the filename with that number and
    # set the tracknum tag.
    #
    class Inumber < Base
      include Aur::Renamers

      def run
        number = validate(new_number)
        tagger.tag!(t_num: number)
        rename_file(file, renumbered_file(number))
      rescue ArgumentError => e
        pp e
        abort 'Invalid input.'
      end

      def new_number
        print "#{file.basename} > "
        $stdin.gets.chomp
      end

      def validate(input)
        return input.to_i if /^\d+$/.match?(input)

        raise(Aur::Exception::InvalidInput, input)
      end

      def self.help
        <<~EOHELP
          usage: aur inumber <file>...

          For each given file, asks for a track number. This number is used to
          prefix the filename, and applied as a tag.
        EOHELP
      end
    end
  end
end

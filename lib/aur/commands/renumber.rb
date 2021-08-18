# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'
require_relative '../stdlib/numeric'

module Aur
  module Command
    #
    # Increments the track number tag, and the filename number, by the given
    # value. This value may be negative.
    #
    class Renumber < Base
      include Aur::Renamers

      def run
        delta = validate(opts[:'<number>'])

        delta = 0 - delta if opts[:down]

        new_number = calculate_new_number(delta)
        tagger.tag!(t_num: new_number)
        rename_file(file, renumbered_file(new_number))
      rescue ArgumentError => e
        pp e
        abort 'Invalid input.'
      end

      def calculate_new_number(delta)
        info.our_tags[:t_num].to_i + delta
      end

      def validate(input)
        return input.to_i if /^\d+$/.match?(input) && input.to_i.positive?

        raise(Aur::Exception::InvalidValue, input)
      end

      def self.help
        <<~EOHELP
          usage: aur renumber (up|down) <value> <file>...

          'renumber' changes the track number of the given file(s) by the given
          integer value in the given direction. It modifies the track number
          tag and the track number at the beginning of the filename.

          An error is thrown if a tag number drops below one.
        EOHELP
      end
    end
  end
end

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
    class Bump < Base
      include Aur::Renamers

      def run
        delta = validate(opts[:'<number>'])
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
        return input.to_i if /^-?\d+$/.match?(input)

        raise(Aur::Exception::InvalidValue, input)
      end

      def self.help
        <<~EOHELP
          usage: aur bump <value> <file>...

          'bump' increments the track number of the given file(s) by the given
          integer value. It changes the track number tag and the track number at
          the beginning of the filename.

          Negative values can be given, which will decrement the track number.
          An error is thrown if a tag number drops below one.
        EOHELP
      end
    end
  end
end

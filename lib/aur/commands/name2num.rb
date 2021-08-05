# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Set the track number tag from the file name.
    #
    class Name2num < Base
      def run
        track_number = info.f_t_num.to_i

        if track_number.zero?
          warn 'No number found at start of filename'
          return
        end

        tagger.tag!(t_num: track_number)
      end

      def self.help
        <<~EOHELP
          usage: aur name2num <file>...

          If the first field of a dot-separated filename is numeric, the track
          number tag is set to its value.
        EOHELP
      end
    end
  end
end

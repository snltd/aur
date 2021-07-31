# frozen_string_literal: true

require_relative 'base'

module Aur
  module Number
    #
    # Set the track number tag from the file name.
    #
    class Generic < Aur::Base
      def run
        track_number = info.f_t_num.to_i

        if track_number.zero?
          warn 'No number found at start of filename'
          return
        end

        tagger.tag!(t_num: track_number)
      end
    end
  end
end

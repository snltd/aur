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

        msg format('%12<tag_name>s -> %<tag_value>s',
                   tag_name: 'track_number',
                   tag_value: track_number)
        tagger.tag!(info.tag_for(:t_num) => track_number)
      end
    end
  end
end

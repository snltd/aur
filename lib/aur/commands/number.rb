# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../tag_edit'
require_relative '../fileinfo'
require_relative '../stdlib/string'

module Aur
  module Number
    #
    # Set the track number tag from the file name.
    #
    class Generic < Aur::Base
      include Aur::TagEdit

      def run
        track_number = info.f_t_num.to_i

        if track_number.zero?
          warn 'No number found at start of filename'
          return
        end

        msg format('%12<tag_name>s -> %<tag_value>s',
                   tag_name: 'track_number',
                   tag_value: track_number)
        apply_tag(track_number)
      end
    end

    # Set the track number of a FLAC
    #
    class Flac < Generic
      def apply_tag(track_number)
        info.raw.comment_del('TRACKNUMBER')
        info.raw.comment_add("TRACKNUMBER=#{track_number}")
        info.raw.update!
      end
    end

    # Set the track number of an MP3
    #
    class Mp3 < Generic
      def apply_tag(track_number)
        Mp3Info.open(file) { |f| f.tag.tracknum = track_number }
      end
    end
  end
end

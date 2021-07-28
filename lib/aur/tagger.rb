# frozen_string_literal: true

module Aur
  module Tagger
    #
    # Base class for specialised taggers. Each tagger presents the same
    # interface.
    #
    class Base
      def initialize(info)
        @info = info
      end
    end

    # Set tags for FLACs.
    #
    class Flac < Base
      # @param tags [Hash] of tag_name => tag_value
      #
      def tag!(tags)
        tags.each_pair do |name, value|
          tag_name = name.to_s.upcase
          @info.raw.comment_del(tag_name)
          @info.raw.comment_add("#{tag_name}=#{value}")
        end

        @info.raw.update!
      end
    end

    # Set Tags for MP3s.
    #
    class Mp3 < Base
      def tag!(tags)
        Mp3Info.open(@info.file) do |f|
          tags.each_pair { |name, value| f.tag[name.to_s] = value }
        end
      end
    end
  end
end

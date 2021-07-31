# frozen_string_literal: true

require_relative 'logger'

module Aur
  module Tagger
    #
    # Base class for specialised taggers. Each tagger presents the same
    # interface.
    #
    class Base
      attr_reader :info, :opts

      include Aur::Logger

      AS_INTS = %i[year t_num].freeze

      # @param info [Aur::Fileinfo::*]
      # @param opts [Hash]
      def initialize(info, opts = {})
        @info = info
        @opts = opts
      end

      def tag_msg(tags)
        tags.each_pair do |name, value|
          msg format('%12<tag_name>s -> %<tag_value>s',
                     tag_name: name,
                     tag_value: value)
        end
      end

      # Certain tags should be certain types
      #
      def prep(tags)
        tags.tap do |t|
          t.each_pair do |k, v|
            t[k] = v.to_i if AS_INTS.include?(k) && v.is_a?(String)
          end
        end
      end
    end

    # Set tags for FLACs.
    #
    class Flac < Base
      # @param tags [Hash] of tag_name => tag_value
      #
      def tag!(tags)
        tag_msg(tags)

        tags.each_pair do |name, value|
          # puts "setting #{info.tag_for(name)}=#{value}"
          info.raw.comment_del(info.tag_name(name))
          info.raw.comment_add("#{info.tag_name(name)}=#{value}")
        end

        info.raw.update!
      end
    end

    # Set Tags for MP3s.
    #
    class Mp3 < Base
      def tag!(tags)
        tag_msg(tags)

        tags = prep(tags)

        Mp3Info.open(info.file) do |mp3|
          tags.each_pair do |name, value|
            mp3.tag[info.tag_name(name)] = value
          end
        end
      end
    end
  end
end

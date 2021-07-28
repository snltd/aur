# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../make_tag'
require_relative '../stdlib/string'

module Aur
  module Name2tag
    #
    # Retag a file from its name
    #
    class Generic < Aur::Base
      TAGS = %i[artist title album t_num].freeze
      include Aur::MakeTag

      def run
        puts file
        tags = tags_from_filename
        tags.each_pair { |k, v| tag_msg(k, v) }
        apply_tags(tags)
      end

      private

      # @return [Hash] tag_name => value
      #
      def tags_from_filename
        TAGS.each_with_object({}) do |t, a|
          a[info.send(:tag_for, t)] = mk_title(info.send("f_#{t}".to_sym))
        end
      end

      def tag_msg(name, val)
        msg format('%12<tag_name>s -> %<tag_value>s',
                   tag_name: name,
                   tag_value: val)
      end
    end

    # Re-tag FLACs
    #
    class Flac < Generic
      def apply_tags(tags)
        tags.each_pair do |k, v|
          info.raw.comment_del(k.to_s.upcase)
          info.raw.comment_add("#{k.upcase}=#{v}")
        end

        info.raw.update!
      end
    end

    # Re-tag MP3s
    #
    class Mp3 < Generic
      def apply_tags(tags)
        Mp3Info.open(file) do |f|
          f.tag.title = tags[:title]
          f.tag.artist = tags[:artist]
          f.tag.album = tags[:album]
          f.tag.tracknum = tags[:tracknum].to_i
        end
      end
    end
  end
end

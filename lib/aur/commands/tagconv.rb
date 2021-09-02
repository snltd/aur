# frozen_string_literal: true

require 'mp3info'
require_relative 'base'

module Aur
  module Command
    #
    # Promotes ID3v1 tags to ID3v2 tags if the former are all a file has.
    # ID3v1 is an absolute shower, and getting tags is pot-luck. This makes a
    # best-guess effort that is deemed to "do".
    #
    class Tagconv < Base
      def run
        v1_tags = info.raw.tag1
        v2_tags = info.our_tags

        promote_v1_tags(v1_tags) if needs_retagging?(v2_tags)
        remove_v1_tags(v1_tags) unless v1_tags.empty?
      end

      def needs_retagging?(tags)
        tags[:artist].nil? || tags[:title].nil?
      end

      def promote_v1_tags(v1_tags)
        tagger.tag!(convert_tags(v1_tags))
      end

      def convert_tags(v1_tags)
        tags = v1_tags.transform_keys(&:to_sym)
                      .transform_values(&:to_s)
                      .tap do |t|
          t[:genre] = t[:genre_s] if t.key?(:genre_s)
          t[:t_num] = t[:tracknumber] if t.key?(:tracknumber)
        end

        tags.select { |k, _v| info.tag_map.key?(k) }
      end

      def remove_v1_tags(v1_tags)
        puts "       Removing #{v1_tags.size} ID3v1 tags"
        Mp3Info.removetag1(file)
      end

      def self.help
        <<~EOHELP
          usage: aur tagconv <file>...

          If a file only has ID3v1 tags, move them to ID3v2.
        EOHELP
      end
    end
  end
end

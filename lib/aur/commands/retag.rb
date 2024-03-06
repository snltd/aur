# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Reads the tags on a file, and writes them again. The side-effect of this
    # is that tags like "title", "Title", and "TITLE" get flattened into
    # "TITLE".
    #
    class Retag < Base
      def run
        return unless opts[:force] || retag?(info.tag_names, info.rawtags)

        tagger.tag!(info.our_tags.transform_values(&:strip))
      end

      def retag?(tag_names, rawtags)
        tag_names.each_value do |t|
          unless rawtags.key?(t) &&
                 rawtags.keys.count { |k| k.casecmp(t).zero? } == 1
            return true
          end
        end

        false
      end

      def self.help
        <<~EOHELP
          usage: aur retag <file>...

          Rewrites a file's tags, thereby removing any mixed-case duplicates.
        EOHELP
      end
    end

    # MP3s do something different: they turn a tag into ASCII.
    #
    module RetagMp3
      def run
        info.our_tags.each do |tag, val|
          next if val.nil?

          if val.bytes[0..2] == [239, 187, 191]
            tagger.tag!(tag => val.bytes[3..].pack('c*'))
          end
        end
      end
    end
  end
end

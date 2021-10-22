# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Removes embedded images and unwanted tags from the given file.
    #
    class Strip < Base
      def run
        remove_extra_tags if info.incorrect_tags?
        tagger.remove_picture if info.picture?
      end

      def remove_extra_tags
        surplus_tags = extra_tags

        return if surplus_tags.empty?

        puts "Surplus tags in #{file}: #{surplus_tags.join(', ')}"
        tagger.untag!(surplus_tags)
      end

      def self.help
        <<~EOHELP
          usage: aur strip <file>...

          Removes embedded images and unwanted tags from the given file(s).
          Stripping an MP3 also removes ID3v1 tags.
        EOHELP
      end
    end

    # FLACs need extra work on tag names
    #
    module StripFlac
      def extra_tags
        real_tags(info.raw.comment, info.tags.keys.sort - info.required_tags)
      end

      # Tag case can be all over the place, and the lib needs it to be
      # correct. You can even have two tags with the same (differently cased)
      # name. This method finds the exact tag names from the given lower-cased
      # ones
      #
      # @param real [Array[String]] the tags (key=val) in the file, mixed case
      # @param ideal [Array[String]] the tag keys we want, lower case
      # @return [Array[String]] subset of @real
      #
      def real_tags(real, ideal)
        real_keys = real.map { |t| t.split('=').first }
        real_keys.select { |k| ideal.include?(k.downcase.to_sym) }
      end
    end

    # Fallback for MP3s
    #
    module StripMp3
      def extra_tags
        info.tags.keys.sort - info.required_tags
      end
    end
  end
end

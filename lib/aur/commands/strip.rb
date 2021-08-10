# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Removes embedded images and unwanted tags from the given file.
    #
    class Strip < Base
      # include Aur::Renamers

      def run
        remove_extra_tags if info.incorrect_tags?
        tagger.remove_picture if info.picture?
      end

      def remove_extra_tags
        surplus_tags = info.tags.keys.sort - info.required_tags

        puts "Surplus tags: #{surplus_tags.join(', ')}"
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
  end
end

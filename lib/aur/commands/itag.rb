# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Interactively tag files. Does not change the filename. (Though maybe it
    # should?)
    #
    class Itag < Base
      def run
        tag = opts[:'<tag>'].to_sym
        # We don't need to validate the tag value, the tagger class does that,
        # but we should make sure the user is applying a tag we care about.
        valid_tag?(tag)
        value = read_tag(tag)
        tagger.tag!(tag.to_sym => value)
      end

      def valid_tag?(tag)
        return true if info.our_tags.keys.include?(tag)

        raise Aur::Exception::InvalidTagName
      end

      def read_tag(tag)
        print "#{file.basename}[#{tag}] > "
        $stdin.gets.chomp.strip
      end

      def self.help
        <<~EOHELP
          usage: aur itag <tag> <file>...

          For each given file, prompts the user for a tag value, and applies
          it for the given tag.
        EOHELP
      end
    end
  end
end

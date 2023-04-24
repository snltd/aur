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
        tagger.tag!(info.our_tags)
      end

      def self.help
        <<~EOHELP
          usage: aur retag <file>...

          Rewrites a file's tags, thereby removing any mixed-case duplicates.
        EOHELP
      end
    end

    # Fallback for MP3s
    #
    module RetagMp3
      def run
        warn 'Not implemented for MP3s'
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Removes embedded images and unwanted tags from the given file.
    #
    class Strip < Base
      # include Aur::Renamers

      def run_flac
        remove_extra_tags if info.incorrect_tags?
        remove_picture_flac if info.picture?
      end

      def run_mp3
        remove_extra_tags if info.incorrect_tags?
        remove_picture_mp3 if info.picture?
      end

      # flacinfo-rb doesn't appear to provide a way to manipulate blocks, so
      # it can't remove a picture. We'll have to shell out to metaflac(1).
      #
      def remove_picture_flac
        res = system(construct_cmd_flac(file))

        raise Aur::Exception::FailedOperation("strip #{file}") unless res
      end

      def construct_cmd_flac(file)
        "#{BIN[:metaflac]} --remove --block-type=PICTURE,PADDING " \
          "--dont-use-padding \"#{file}\""
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
        EOHELP
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'mp3dir'
require_relative '../constants'
require_relative 'mixins/file_tree'

module Aur
  module Command
    #
    # Makes sure we have MP3s of all our FLACs
    #
    class Syncflac
      include Aur::Mixin::FileTree

      def initialize(root, _opts = {})
        @root = root
      end

      def run
        dirs = dirs_under(@root.join('flac'), CONF.fetch(:syncflac_omit, []))

        dirs.each { |d, _count| Aur::Command::Mp3dir.new(d).run }
      end

      def self.screen_flist(_flist, _opts)
        [DATA_DIR]
      end

      def self.help
        <<~EOHELP
          usage: aur syncflac

          Makes sure there is a corresponding MP3 for every FLAC we have.
          Assumes FLACS are in /storage/flac and MP3s in /storage/mp3. If any
          MP3 directories have audio files with no corresponding FLAC, they
          are removed, unless they are in a tracks/ directory.

          Uses the same encoding as the 'mp3dir' command.
        EOHELP
      end
    end
  end
end

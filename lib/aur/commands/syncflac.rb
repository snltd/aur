# frozen_string_literal: true

require_relative 'mp3dir'
require_relative 'mixins/file_tree'

module Aur
  module Command
    #
    # Makes sure we have MP3s of all our FLACs
    #
    class Syncflac
      attr_reader :fdir, :mdir

      include Aur::Mixin::FileTree

      def initialize(root, _opts = {})
        @fdir = root + 'flac'
        @mdir = root + 'mp3'
      end

      def run
        to_be_synced(flacs, mp3s).each { |dir| sync(dir) }
      end

      def flacs
        content_under(fdir, '.flac')
      end

      def mp3s
        content_under(mdir, '.mp3')
      end

      def sync(dir)
        Aur::Command::Mp3dir.new(dir).run
      end

      # @return [Array[Pathname]] fully qualified paths of FLAC directories
      #   which need mp3ing.
      #
      def to_be_synced(flacdirs, mp3dirs)
        (flacdirs - mp3dirs).map { |d| fdir + d.first }
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

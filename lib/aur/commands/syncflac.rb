# frozen_string_literal: true

require_relative 'mp3dir'
require_relative 'mixins/file_tree'

module Aur
  module Command
    #
    # Makes sure we have MP3s of all our FLACs
    #
    class Syncflac
      attr_reader :fdir, :mdir, :opts

      include Aur::Mixin::FileTree

      def initialize(root, opts = {})
        @opts = opts
        @fdir = root + 'flac'
        @mdir = root + 'mp3'
      end

      def run
        if opts[:deep]
          deep_difference(flacs)
        else
          difference(flacs, mp3s).each { |dir| action(dir) }
        end
      end

      def flacs
        content_under(fdir, '.flac')
      end

      def mp3s
        content_under(mdir, '.mp3')
      end

      def action(dir)
        Aur::Command::Mp3dir.new(dir).run
      end

      # @return [Array[Pathname]] fully qualified paths of FLAC directories
      #   which need mp3ing.
      #
      def difference(flacdirs, mp3dirs)
        (flacdirs - mp3dirs).map { |d| fdir + d.first }.reject do |d|
          d.to_s.end_with?('/new') || d.to_s.include?('/new/')
        end
      end

      def deep_difference(flacdirs)
        flacdirs.each { |d, _count| action(fdir + d) }
      end

      def self.screen_flist(_flist, _opts)
        [Pathname.new('/storage')]
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

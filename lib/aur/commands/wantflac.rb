# frozen_string_literal: true

require_relative '../constants'
require_relative 'mixins/file_tree'

module Aur
  module Command
    #
    # Shows which things we have as MP3 but not as FLAC
    #
    class Wantflac
      include Aur::Mixin::FileTree

      def initialize(root, opts = {})
        @root = root
        @opts = opts
      end

      def run
        @conf = CONF.fetch(:wantflac_ignore, {})

        extend Aur::Command::WantflacTracks if @opts[:tracks]

        puts difference
      end

      def difference
        ignores = @conf.fetch(:top_level, [])

        (string_map(mp3s) - string_map(flacs) - @conf.fetch(:dirs,
                                                            [])).reject do |d|
          ignores.any? { |tl| d.start_with?(tl) }
        end
      end

      def flacs
        content_under(@root.join('flac'), '.flac')
      end

      def mp3s
        content_under(@root.join('mp3'), '.mp3')
      end

      def self.screen_flist(_flist, _opts)
        [DATA_DIR]
      end

      def self.help
        <<~EOHELP
          usage: aur wantflac

          Lists MP3 albums and EPs which we do not have as FLACs. With the -T
          flag, lists tracks.
        EOHELP
      end

      private

      def string_map(dirs)
        dirs.map { |d| d.first.to_s }
      end

      def ignore(type)
        @conf.fetch(type, []).map { |f| "#{f}.flac" }
      end
    end

    # Handles loose tracks
    #
    module WantflacTracks
      def difference
        (mp3_list - flac_list - ignore(:tracks)).sort
      end

      def mp3_list
        @root.join('mp3', 'tracks').children.map do |f|
          f.basename.to_s.sub(/mp3$/, 'flac')
        end
      end

      def flac_list
        @root.join('flac', 'tracks').children.map { |f| f.basename.to_s }
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'syncflac'
require_relative '../constants'

module Aur
  module Command

    #
    # Shows which things we have as MP3 but not as FLAC
    #
    class Wantflac < Syncflac
      def run
        @conf = CONF.fetch(:wantflac_ignore, {})

        extend Aur::Command::WantflacTracks if opts[:tracks]

        #difference(flacs, mp3s).each { |dir| action(dir) }
        puts difference
      end

      def action(dir)
        puts dir
      end

      def difference
        (string_map(mp3s) - string_map(flacs)).reject do |d|
          @conf.fetch(:dirs, []).include?(d) ||
          @conf.fetch(:top_level, []).any? { |tl| d.start_with?(tl) }
        end
      end

      def string_map(dirs)
        dirs.map { |d| d.first.to_s }
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
        mdir.join('tracks').children.map do |f|
          f.basename.to_s.sub(/mp3$/, 'flac')
        end
      end

      def flac_list
        fdir.join('tracks').children.map { |f| f.basename.to_s }
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'syncflac'
require_relative '../constants'

module Aur
  module Command
    #
    # Shows which things we have as MP3 but not as FLAC
    #
    class Wantflac < Syncflac
      UNWANTED_DIRS = %w[language radio_sessions radio_shows spoken_word].freeze

      def run
        if opts[:tracks]
          track_difference
        else
          difference(flacs, mp3s).each { |dir| action(dir) }
        end
      end

      def action(dir)
        puts dir
      end

      def track_difference
        flacs = flac_track_filenames

        puts mdir.join('tracks').children.each_with_object([]) { |f, aggr|
          bn = f.basename.to_s
          aggr << bn unless flacs.key?(bn.sub(/mp3$/, 'flac'))
        }.sort
      end

      def difference(flacdirs, mp3dirs)
        filter(mp3dirs - flacdirs).filter_map do |d|
          album_name(d.first)
        end.sort.uniq
      end

      # Filter out things we can't possibly get FLACs for
      #
      def filter(dirs)
        dirs.select { |d| filter_path(d) }
      end

      def filter_path(path)
        bits = path.first.to_s.split('/')

        !(UNWANTED_DIRS.include?(bits.first) ||
          (bits[0] == 'christmas' && bits[1] == 'spackers'))
      end

      def album_name(path)
        path = path.to_s

        if path.start_with?('new/') || path.include?('/new/') ||
           !path.include?('.')
          return nil
        end

        path.match(%r{/([^/]+\.[^/]+)})[1]
      end

      def self.screen_flist(_flist, _opts)
        [DATA_DIR]
      end

      def self.help
        <<~EOHELP
          usage: aur wantflac

          Lists MP3 albums and EPs which we do not have as FLACs. With the -t
          flag, lists tracks.
        EOHELP
      end

      private

      def flac_track_filenames
        fdir.join('tracks').children.to_h { |f| [f.basename.to_s, true] }
      end
    end
  end
end

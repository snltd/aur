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
        (mp3dirs - flacdirs).filter_map { |d| album_name(d.first) }.sort.uniq
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

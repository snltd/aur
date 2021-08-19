# frozen_string_literal: true

require_relative 'base'
require_relative '../fileinfo'

module Aur
  module Command
    #
    # Display information about the files in a directory
    #
    class Ls
      def initialize(dir = nil, opts = {})
        @dir = dir
        @opts = opts
      end

      def run
        @dir.children.sort.each do |f|
          next unless f.extname == '.flac'
          info = Aur::FileInfo::Flac.new(f)
          puts format('%02<t_num>d %-40<artist>s %-60<title>s %<album>s',
            artist: info.artist,
            title: info.title,
            t_num: info.t_num.to_i,
            album: info.album)
        end
      end

      def self.help
        <<~EOHELP
          usage: aur ls <directory>...

          Shows tag and bitrate information about the given file(s).
        EOHELP
      end
    end
  end
end

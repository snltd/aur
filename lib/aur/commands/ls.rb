# frozen_string_literal: true

require_relative 'base'
require_relative '../fileinfo'

module Aur
  module Command
    #
    # Display information about the files in a directory. It adapts very
    # roughly to terminal width. I was going to shrink oversized fields with
    # ellipses, but that maybe defeats the object. I'll see how it goes in
    # real usage.
    #
    class Ls
      def initialize(dir = nil, opts = {})
        @dir = dir
        @format = if opts[:delim]
                    delimited_format_string(opts[:delim])
                  else
                    format_string(TW)
                  end
      end

      def run
        @dir.children.sort.each do |f|
          info = process_entry(f)
          puts format_line(@format, info) if info
        end
      end

      def process_entry(file)
        Aur::FileInfo.new(file)
      rescue Aur::Exception::UnsupportedFiletype
        nil
      end

      def format_line(format_str, info)
        format(format_str, artist: info.artist,
                           title: info.title,
                           t_num: info.t_num.to_i,
                           album: info.album)
      end

      def delimited_format_string(delim)
        "%02<t_num>d#{delim}%<artist>s#{delim}%<title>s#{delim}%<album>s"
      end

      def format_string(width)
        tnum_col = 2
        title_col = width / 2
        artist_col = (width / 4)
        album_col = width - title_col - artist_col - 5

        "%0#{tnum_col}<t_num>d " \
          "%-#{artist_col}<artist>s " \
          "%-#{title_col}<title>s " \
          "%#{album_col}<album>s"
      end

      def self.help
        <<~EOHELP
          usage: aur ls [-r] [-s separator] <directory>...

          Shows tag information about files in the given directory, one file
          per line. Operates recursively with -r.

          -s produces machine-parseable output with the specified field
          separator.
        EOHELP
      end
    end
  end
end

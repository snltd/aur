# frozen_string_literal: true

require 'fileutils'
require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'

module Aur
  module Command
    #
    # Move files into artist.title directories
    #
    class Sort < Base
      include Aur::Renamers

      def run
        dest = dest_file
        create_dir(dest.dirname)
        rename_file(file, dest)
      end

      def self.help
        <<~EOHELP
          usage: aur sort <file>...

          Puts each file in a directory derived from file's artist and album
          tags. Useful for separating out mixed-up albums.
        EOHELP
      end

      private

      def create_dir(dir)
        FileUtils.mkdir_p(dir)
      end

      def dest_dir
        file.dirname + format('%<artist>s.%<album>s',
                              artist: artist_fname(info),
                              album: album_fname(info))
      end

      def dest_file
        dest_dir + file.basename
      end

      def rename_message(file, dest)
        msg format('%<from>s -> %<to>s/',
                   from: file.basename,
                   to: dest.dirname.basename)
      end
    end
  end
end

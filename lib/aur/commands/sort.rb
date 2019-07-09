# frozen_string_literal: true

require 'fileutils'
require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'

module Aur
  module Sort
    #
    # Move files into artist.title directories
    #
    class Generic < Aur::Base
      include Aur::Renamers

      def run
        dest = dest_file
        create_dir(dest.dirname)
        rename_file(file, dest)
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

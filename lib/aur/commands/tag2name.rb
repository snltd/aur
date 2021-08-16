# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'

module Aur
  module Command
    #
    # Rename a file from its tags
    #
    class Tag2name < Base
      include Aur::Renamers

      def run
        rename_file(file, dest_file)
      end

      # Normally this won't be called with an arg, but we allow it
      # (and make it public) to facilitate testing.
      #
      def safe_filename(info = @info)
        [track_fnum(info),
         artist_fname(info),
         track_fname(info),
         file_suffix(info)].join('.')
      end

      def self.help
        <<~EOHELP
          usage: aur tag2name <file>...

          Renames a file based on its tags. The pattern is

            <track_num>.<artist>.<title>.suffix

          track_num is two zero-padded digits; artist is turned to lower
          snake-case with non-alnum characters removed, and any leading 'the_'
          stripped off; title is lower snake-cased
        EOHELP
      end

      private

      def dest_file
        file.dirname + safe_filename
      end
    end
  end
end

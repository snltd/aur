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

      private

      def dest_file
        file.dirname + safe_filename
      end
    end
  end
end

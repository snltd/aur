# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'

module Aur
  module NumName
    #
    # Prefix a file's name with its track number
    #
    class Generic < Aur::Base
      include Aur::Renamers

      def run
        rename_file(file, dest_file)
      end

      # @return [String] filename prefixed with track number
      #
      def new_filename(info = @info)
        format('%<number>s.%<fname>s',
               number: track_fnum(info),
               fname: file.basename.to_s)
      end

      private

      def dest_file
        file.dirname + new_filename
      end
    end
  end
end

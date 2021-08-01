# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'

module Aur
  module Command
    #
    # Prefix a file's name with its track number. If there's no track number,
    # it will prefix with '00'.
    #
    class Numname < Base
      include Aur::Renamers

      def run
        prefix = file.basename.to_s.split('.').first
        num = track_fnum(info)

        if prefix == num
          puts 'No change required.'
        else
          rename_file(file, dest_file)
        end
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

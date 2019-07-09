# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'

module Aur
  module Inumber
    #
    # Prefix a file's name with its track number
    #
    class Generic < Aur::Base
      include Aur::Renamers

      def run
        rename_file(file, dest_file)
      end

      def track_fnum(_info)
        print "#{file.basename} > "
        STDIN.gets.chomp
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../stdlib/string'
require_relative '../stdlib/numeric'

module Aur
  module Inumber
    #
    # Ask the user for a number, then prefix the filename with that number and
    # set the tracknum tag.
    #
    class Generic < Aur::Base
      include Aur::Renamers

      def run
        number = validate(new_number)
        tagger.tag!(info.tag_for(:t_num).to_s => number)
        rename_file(file, dest_file(number))
      rescue ArgumentError => e
        pp e
        abort 'Invalid input.'
      end

      def new_number
        print "#{file.basename} > "
        $stdin.gets.chomp
      end

      def dest_file(number, tfile = file)
        if /^\d\d\./.match?(tfile.basename.to_s)
          tfile.dirname + tfile.basename.to_s.sub(/^\d\d/, number.to_n)
        else
          tfile.dirname + [number.to_n, tfile.basename.to_s].join('.')
        end
      end

      def validate(input)
        return input.to_i if /^\d+$/.match?(input)

        raise ArgumentError
      end
    end
  end
end

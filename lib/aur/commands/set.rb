# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Set the given tag(s) in the given file(s)
    #
    class Set < Base
      def run
        val = opts[:'<value>']
        val = nil if val == 'NIL'

        tagger.tag!(opts[:'<tag>'].to_sym => val)
      end

      def self.help
        require_relative '../fileinfo'

        <<~EOHELP
          usage: aur set <tag> <value> <file>...

          Sets one tag to the same value across any number of files. The tag
          must be one of:

            artist
            album
            title
            t_num
            year
            genre

          Setting year to the string NIL clears its value.
        EOHELP
      end
    end
  end
end

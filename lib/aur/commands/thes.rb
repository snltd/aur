# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../make_tag'
require_relative '../stdlib/string'

module Aur
  module Command
    #
    # Put "The" before the artist name
    #
    class Thes < Base
      include Aur::MakeTag

      def run
        new = new_name(info.artist)

        tagger.tag!(artist: new) if new
      end

      def new_name(orig_name)
        orig_name.start_with?('The ') ? false : "The #{orig_name}"
      end

      def self.help
        <<~EOHELP
          usage: aur thes <file>...

          We strip "the_" off the start of band names. This means that running
          name2tag results on missing "The"s. This command helps put them back
          by prefixing the ARTIST tag with "The ". (Unless it's already there.)
        EOHELP
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../stdlib/string'

module Aur
  module Command
    #
    # If it doesn't already have it, add (Disc n) to the album title, assuming
    # the file is in a disc_n directory.
    #
    class Albumdisc < Base
      def run
        disc_number = disc_number(file)

        if disc_number.nil?
          raise Aur::Exception::InvalidInput, 'file is not in disc_n directory'
        end

        new_album = new_album(info.album, disc_number)

        tagger.tag!(album: new_album) unless new_album.nil?
      end

      def disc_number(file)
        matches = file.dirname.basename.to_s.match(/disc_(\d+)$/)

        matches.nil? ? nil : matches[1].to_i
      end

      def new_album(album, disc)
        return nil if album.match(/\(Disc \d+\)$/)

        "#{album} (Disc #{disc})"
      end

      def self.help
        require_relative '../fileinfo'

        <<~EOHELP
          usage: aur retitle <file>...

          Fix the title capitalization on the given file(s).
        EOHELP
      end
    end
  end
end

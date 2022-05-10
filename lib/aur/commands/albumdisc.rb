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
        return nil if /\(Disc \d+\)$/.match?(album)

        "#{album} (Disc #{disc})"
      end

      def self.help
        require_relative '../fileinfo'

        <<~EOHELP
          usage: aur albumdisc <file>...

          If a file is in a disc_n directory, add (Disc n) to the album tag,
          if it isn't there already.
        EOHELP
      end
    end
  end
end

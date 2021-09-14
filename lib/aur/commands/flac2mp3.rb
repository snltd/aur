# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../renamers'
require_relative 'mixins/flac2mp3'

module Aur
  module Command
    #
    # Re-encode a FLAC as an MP3, using preset parameters
    #
    class Flac2mp3 < Base
      include Aur::Renamers
      include Aur::Mixin::Flac2mp3

      def self.help
        <<~EOHELP
          usage: aur flac2mp3 <file>...

          Converts a FLAC into an MP3 using following preset values.

            #{LAME_FLAGS}

          The new MP3 file is created in the same directory as the FLAC, with
          the same filename, barring the suffix.

          Tags are copied from the FLAC.
        EOHELP
      end
    end

    # Transcode a single FLAC
    #
    module Flac2mp3Flac
      def run
        check_dependencies
        info = Aur::FileInfo.new(file)
        dest = file.sub_ext('.mp3')
        cmd = construct_command(file, dest, info.our_tags)
        puts "#{file} -> #{dest}"
        system(cmd)
      end
    end

    # We don't turn mp3s into mp3s
    #
    module Flac2mp3Mp3
      def run
        raise Aur::Exception::UnsupportedFiletype
      end
    end
  end
end

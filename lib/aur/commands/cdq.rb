# frozen_string_literal: true

require_relative 'reencode'

module Aur
  module Command
    #
    # Dither a hi-res file to CD-quality with `ffmpeg`.
    #
    class Cdq < Reencode
      include Aur::Renamers

      def construct_cmd(file1, file2)
        "#{BIN[:ffmpeg]} -hide_banner -loglevel error -i #{escaped(file1)} " +
          "#{CDQ_FFMPEG_FLAGS} #{escaped(file2)}"
      end

      def self.help
        <<~EOHELP
          usage: aur cdq <file>...

          Uses ffmpeg to dither the given files to 16-bit/44100Hz samples.
        EOHELP
      end
    end
  end
end

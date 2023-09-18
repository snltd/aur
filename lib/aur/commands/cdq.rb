# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative 'mixins/reencoders'

module Aur
  module Command
    #
    # Dither a hi-res file to CD-quality with `ffmpeg`.
    #
    class Cdq < Base
      include Aur::Renamers
      include Aur::Reencoders

      def run
        if info.bitrate == '16-bit/44100Hz'
          puts 'File is already CD quality.'
        else
          operate_and_overwrite(file)
        end
      end

      def construct_cmd(file1, file2)
        "#{BIN[:ffmpeg]} -hide_banner -loglevel error -i #{escaped(file1)} " \
          "#{CDQ_FFMPEG_FLAGS} #{escaped(file2)}"
      end

      def self.help
        <<~EOHELP
          usage: aur cdq <file>...

          Uses ffmpeg to dither the given files to 16-bit/44100Hz samples.
        EOHELP
      end
    end

    # Command makes no sense for MP3s
    #
    module CdqMp3
      def run
        puts "Can't convert lossy to lossless."
      end
    end
  end
end

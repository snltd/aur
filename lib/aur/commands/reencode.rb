# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../constants'
require_relative 'mixins/reencoders'

module Aur
  module Command
    #
    # Reencode a file with `ffmpeg`. This fixes files which flacinfo-rb and
    # flac(1) cannot recognize as FLACs. Is there anything ffmpeg can't do?
    #
    class Reencode < Base
      include Aur::Renamers
      include Aur::Reencoders

      # Overridden so we can reencode files which flacinfo-rb can't parse,
      # which is kind of the point of this command.
      #
      def setup_tagger; end

      def setup_info; end

      def run
        operate_and_overwrite(file)
      end

      # OmniOS's ffmpeg doesn't have MP3 support, and I'm tired of maintaining
      # my own version. So, use LAME to reencode MP3s. I don't know if I've
      # ever even used this.  The if hack is because we aren't using the
      # automatic subclass loader
      #
      def construct_cmd(file1, file2)
        return lame_cmd(file1, file2) if file2.extname.casecmp('.mp3').zero?

        ffmpeg_cmd(file1, file2)
      end

      # Trying to force id3v2 tags somehow loses all the tags. This preserves
      # them.
      #
      def lame_cmd(file1, file2)
        "#{BIN[:lame]} -q2 --vbr-new --preset 128 --silent #{escaped(file1)} " +
          escaped(file2)
      end

      def ffmpeg_cmd(file1, file2)
        "#{BIN[:ffmpeg]} -hide_banner -loglevel error -i #{escaped(file1)} " \
          "-compression_level 8 #{escaped(file2)}"
      end

      def self.help
        <<~EOHELP
          usage: aur reencode <file>...

          Uses ffmpeg to re-encode a file. The resultant file overwrites the
          original. This can be used to fix "broken" FLACs which have ID3 tags
          and otherwise cannot be understood by aur, or to lower the bitrate
          of MP3s to 128kpbs (variable).
        EOHELP
      end
    end
  end
end

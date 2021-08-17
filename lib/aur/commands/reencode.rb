# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../constants'

module Aur
  module Command
    #
    # Reencode a file with `ffmpeg`. This fixes files which flacinfo-rb and
    # flac(1) cannot recognize as FLACs. Is there anything ffmpeg can't do?
    #
    class Reencode < Base
      include Aur::Renamers

      # Overridden so we can reencode files which flacinfo-rb can't parse,
      # which is kind of the point of this command.
      #
      def setup_tagger; end

      def setup_info; end

      def run
        intermediate_file = file.prefixed

        cmd = construct_cmd(file, intermediate_file)
        puts "#{file} -> #{file} [re-encoded]"

        if system(cmd)
          FileUtils.mv(intermediate_file, file)
        else
          FileUtils.rm(intermediate_file)
          raise Aur::Exception::FailedOperation, "reencode #{file}"
        end
      end

      def construct_cmd(file1, file2)
        "#{BIN[:ffmpeg]} -hide_banner -loglevel error -i #{escaped(file1)} " +
          escaped(file2)
      end

      def check_dependencies
        return if BIN[:ffmpeg].exist?

        raise(Aur::Exception::MissingBinary, BIN[:ffmpeg])
      end

      def self.help
        <<~EOHELP
          usage: aur reencode <file>...

          Uses ffmpeg to re-encode a file. The resultant file overwrites the
          original. This can be used to fix "broken" FLACs which have ID3 tags
          and otherwise cannot be understood by aur.
        EOHELP
      end
    end
  end
end

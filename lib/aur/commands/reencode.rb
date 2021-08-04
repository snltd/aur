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
    end
  end
end

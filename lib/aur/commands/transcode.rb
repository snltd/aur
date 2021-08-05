# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'
require_relative '../constants'

module Aur
  module Command
    #
    # Transcode a file with `ffmpeg`.
    #
    class Transcode < Base
      include Aur::Renamers

      def run
        target = file.sub_ext(".#{opts[:'<newtype>']}")

        cmd = construct_cmd(file, target)
        puts "#{file} -> #{target}"

        return if system(cmd)

        raise Aur::Exception::FailedOperation, "transcode #{file} #{target}"
      end

      def construct_cmd(file1, file2)
        "#{BIN[:ffmpeg]} -hide_banner -loglevel error -i #{escaped(file1)} " +
          escaped(file2)
      end

      def check_dependencies
        return if BIN[:ffmpeg].exist?

        raise(Aur::Exception::MissingBinary, BIN[:ffmpeg])
      end

      # These will never be accessed, so they can be anything.
      #
      def setup_info
        {}
      end

      def setup_tagger
        {}
      end

      def self.help
        <<~EOHELP
          usage: aur transcode <newtype> <file>...

          Uses ffmpeg to transcode the given file(s) to the format given by
          newtype. For instance, 'flac', or 'wav'.
        EOHELP
      end
    end
  end
end

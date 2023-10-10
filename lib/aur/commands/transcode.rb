# frozen_string_literal: true

require_relative 'base'
require_relative '../fileinfo'
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
        target = target_file

        cmd = construct_cmd(file, target)
        puts "#{file} -> #{target}"

        return if system(cmd)

        raise Aur::Exception::FailedOperation, "transcode #{file} #{target}"
      end

      def target_file
        file.sub_ext(".#{opts[:'<newtype>']}")
      end

      def construct_cmd(file1, file2)
        "#{BIN[:ffmpeg]} -hide_banner -loglevel panic -i #{escaped(file1)} " \
          "#{extra_opts(file1, file2)} #{escaped(file2)}"
      end

      def check_dependencies
        return if BIN[:ffmpeg].exist?

        raise(Aur::Exception::MissingBinary, BIN[:ffmpeg])
      end

      def extra_opts(file1, file2)
        f1info = FileInfo.new(file1)

        if file2.extname == '.m4a'
          "-c:a aac -b:a #{f1info.raw_bitrate}"
        else
          ''
        end
      end

      # These will never be accessed, so they can be anything.
      #
      def setup_info
        {}
      end

      def setup_tagger
        {}
      end

      def self.screen_flist(flist, _opts)
        flist.select(&:file?)
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

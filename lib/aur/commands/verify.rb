# frozen_string_literal: true

require_relative 'base'
require_relative '../renamers'

module Aur
  module Command
    #
    # Check the integrity of a file. Doesn't look at tags or anything: that's
    # what we call 'linting'.
    #
    class Verify < Base
      include Aur::Renamers

      def equipped?
        abort "No #{binary} binary." unless BIN[binary].exist?
      end

      def report(valid)
        puts format('%<name>-70s  %<status>s',
                    name: info.file,
                    status: valid ? 'OK' : 'INVALID')
      end

      def self.help
        <<~EOUSAGE
          usage: aur verify <file>...

          Verifies FLACs by calling out to the flac binary. Does not support
          any other file types.
        EOUSAGE
      end
    end

    # Verify FLACs.
    #
    module VerifyFlac
      def binary
        :flac
      end

      def run
        res = system("#{BIN[:flac]} --test --totally-silent #{escaped(file)}")
        report(res)
      end
    end

    # We can't verify MP3s, but we can at least say so.
    #
    module VerifyMp3
      def binary
        :mp3val
      end

      def run
        abort 'No mp3val binary.' unless BIN[:mp3val].exist?

        res = `#{BIN[:mp3val]} #{escaped(file)}`
        report(!res.include?('WARNING'))
      end
    end
  end
end

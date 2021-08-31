# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Check the integrity of a file. Doesn't look at tags or anything: that's
    # what we call 'linting'.
    #
    class Verify < Base
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
      def run
        abort 'No flac binary.' unless BIN[:flac].exist?

        res = system("#{BIN[:flac]} --test --totally-silent #{file}")

        puts format('%<name>-60s  %<status>s',
                    name: info.prt_name,
                    status: res ? 'OK' : 'INVALID')
      end
    end

    # We can't verify MP3s, but we can at least say so.
    #
    module VerifyMp3
      def run
        warn 'MP3 files cannot be verified.'
      end
    end
  end
end

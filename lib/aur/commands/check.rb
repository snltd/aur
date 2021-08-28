# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'

module Aur
  module Command
    #
    # See if we can parse the file. This command dumps filenames to stdout so
    # they can be reencoded, skipping the usual summary
    #
    class Check < Base
      def run; end

      def no_error_report
        true
      end

      def handle_err(file, _err)
        puts file
      end

      def self.help
        <<~EOHELP
          usage: aur check <file>...

          A no-op command which says whether or not this tool can safely
          manipulate the given file(s). It appears the flacinfo-rb library
          does not work correctly with all FLACs.

          If a file is not OK, it must be re-encoded or left entirely alone,
          as rewriting it with aur can result in severely truncated audio.
        EOHELP
      end
    end
  end
end

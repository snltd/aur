# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Split based on a cue file
    #
    class Split < Base
      def run
        abort 'No shnsplit binary.' unless BIN[:shnsplit].exist?

        res = system("#{BIN[:shnsplit]} -f \"#{cuefile}\" -o flac " \
                     "-t \"%n.%p.%t\" \"#{file}\"")
        puts format('%<name>-60s  %<status>s',
                    name: info.prt_name,
                    status: res ? 'OK' : 'FAILED')
      end

      def cuefile
        file.sub(/\.\w+$/, '.cue')
      end

      def self.help
        <<~EOHELP
          usage: aur split <file>...

          Looks for a cue file with the same basename as the given file, and uses
          shnsplit to split the former according to the latter. No tagging is
          done.
        EOHELP
      end
    end
  end
end

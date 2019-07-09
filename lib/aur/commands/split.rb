# frozen_string_literal: true

require_relative 'base'

module Aur
  module Split
    #
    # Split based on a cue file
    #
    class Generic < Aur::Base
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
    end
  end
end

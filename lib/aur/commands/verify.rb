# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Verify FLACs.
    #
    class Verify < Base
      def run
        raise "unsupported filetype: #{info.filetype}"
      end

      def run_flac
        abort 'No flac binary.' unless BIN[:flac].exist?

        res = system("#{BIN[:flac]} --test --totally-silent #{file}")

        puts format('%<name>-60s  %<status>s',
                    name: info.prt_name,
                    status: res ? 'OK' : 'INVALID')
      end

      def run_mp3
        warn 'MP3 files cannot be verified.'
      end
    end
  end
end

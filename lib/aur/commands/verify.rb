# frozen_string_literal: true

require_relative 'base'

module Aur
  module Verify
    #
    # Verify FLACs.
    #
    class Flac < Aur::Base
      def run
        abort 'No flac binary.' unless BIN[:flac].exist?

        res = system("#{BIN[:flac]} --test --totally-silent #{file}")

        puts format('%<name>-60s  %<status>s',
                    name: info.prt_name,
                    status: res ? 'OK' : 'INVALID')
      end
    end

    # You can't verify MP3s
    #
    class Mp3 < Aur::Base
      def run
        warn 'MP3 files cannot be verified.'
      end
    end
  end
end

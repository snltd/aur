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
                     "-t \"%n.%p.%t\" -d \"#{target_dir}\" \"#{file}\"")
        puts format('%<name>-60s  %<status>s',
                    name: info.prt_name,
                    status: res ? 'OK' : 'FAILED')
      end

      def cuefile
        file.sub(/\.\w+$/, '.cue')
      end

      def target_dir
        file.dirname
      end
    end
  end
end

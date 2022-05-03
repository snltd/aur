# frozen_string_literal: true

require_relative 'base'
require_relative '../fileinfo'
require_relative '../helpers'

module Aur
  module Command
    #
    # Display selected information about the given files.
    #
    class Get < Base
      def run
        fields = opts[:'<fields>'].split(',')

        if fields.empty?
          raise Aur::Exception::InvalidInput, 'Requires at least one field'
        end

        puts fields.map { |f| info.send(f) if info.respond_to?(f) }.join('  ')
      end

      def self.help
        <<~EOHELP
          usage: aur get <tags> <file>...

          Shows values for the given tags on the given files.
        EOHELP
      end
    end
  end
end

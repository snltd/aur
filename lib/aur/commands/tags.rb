# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Display raw tag information
    #
    class Tags < Base
      def run
        width = info.rawtags.keys.map(&:length).max

        info.rawtags.sort_by { |k, _v| k.downcase }.each do |k, v|
          puts fmt_line(k, v, width + 3)
        end
      end

      def fmt_line(key, value, width)
        format("%#{width}<key>s : %<value>s", key: key, value: value)
      end

      def self.help
        <<~EOHELP
          usage: aur tags <file>...

          Shows raw tags.
        EOHELP
      end
    end
  end
end

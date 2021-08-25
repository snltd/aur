# frozen_string_literal: true

require_relative '../constants'
require_relative 'base'

module Aur
  module Command
    #
    # Fix, to some degree, the tags on the given file by removing
    # capitalization from words we think should always be downcased. I've
    # chosen this "dumb" approach rather than using smart_capitalize because
    # it will catch 90% of things, and won't mess up punctuation and whatnot.
    #
    class Retitle < Base
      SPACERS = '[ ,.!?]+'

      def run
        original_title = info.title
        new_title = retitle(original_title)

        return if new_title == original_title

        if opts[:noop]
          puts "#{original_title} -> #{new_title}"
        else
          tagger.tag!(title: new_title)
        end
      end

      def retitle(title)
        title.split(/\W/).each_with_object(String.new(title)) do |w, ret|
          next unless NO_CAPS.include?(w.downcase)

          ret.gsub!(%r{(#{SPACERS})#{w}(#{SPACERS})}, "\\1#{w.downcase}\\2")
        end
      end

      def self.help
        require_relative '../fileinfo'

        <<~EOHELP
          usage: aur retitle <file>...

          Fix the title capitalization on the given file(s).
        EOHELP
      end
    end
  end
end

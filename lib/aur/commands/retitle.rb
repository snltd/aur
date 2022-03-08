# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../stdlib/string'

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
        if opts[:all]
          retitle_album
          retitle_title
        elsif opts[:album]
          retitle_album
        else
          retitle_title
        end
      end

      def retitle_album
        original_title = info.album
        new_title = retitle(original_title)

        return if new_title == original_title

        if opts[:noop]
          puts "#{original_title} -> #{new_title}"
        else
          tagger.tag!(album: new_title)
        end
      rescue NoMethodError
        raise Aur::Exception::InvalidTagValue, "#{file} has broken tags"
      end

      def retitle_title
        original_title = info.title
        new_title = retitle(original_title)

        return if new_title == original_title

        if opts[:noop]
          puts "#{original_title} -> #{new_title}"
        else
          tagger.tag!(title: new_title)
        end
      rescue NoMethodError
        raise Aur::Exception::InvalidTagValue, "#{file} has broken tags"
      end

      def retitle(title)
        return nil if title.nil? || title.empty?

        words = [nil] + title.split(/\s/) + [nil]

        # Using / as the previous word forces capitalisation
        words.each_cons(3).map do |before, word, after|
          if before.nil? || after.nil?
            word.titlecase('/')
          else
            word.titlecase(before)
          end
        end.join(' ')
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

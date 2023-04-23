# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Gives the same case to the tags we care about. This avoids double tag
    # errors we see quite often. Leaves other stuff alone because there may be
    # nuance there that I don't understand.
    #
    class Tagflat < Base
      def run
        tagger.tag!(flatten(info.rawtags))
      end

      # If we have the uppercase key, that's great. If not, grab the first
      # we find with a case-insensitive match and promote it.
      # @return [Hash [Symbol => Array]] tags to :add and :destroy
      #
      def flatten(raw_tags)
        ret = { add: {}, destroy: {} }

        info.tag_names.each_value do |t|
          puts "look up #{t}"
          other_case_lookup(t, raw_tags).each_pair do |k, v|
            if k == t
              puts "  ADD #{t} => #{v}"
              ret[:add].merge!({ t => v })
            else
              puts "skip ADD #{t}"
            end
            puts "  DESTROY #{k} => #{v}"
            ret[:destroy].merge!({ k => v })
          end
        end

        ret
      end

      # Returns the pairs of a hash where the key is the same characters as
      # the given one, but are of a DIFFERENT case
      #
      def other_case_lookup(key, hash)
        puts "key is #{key}"
        x = hash.select { |k, _v| k.casecmp(key).zero? }
            .reject { |k, _v| k == key }

        puts "returning #{x}"
        x
      end

      def self.help
        <<~EOHELP
          usage: aur tagflat <file>...

          Flattens the case of the tag keys for FLACs. aur adds uppercase tags,
          so they win.
        EOHELP
      end
    end

    # Fallback for MP3s
    #
    module StripMp3
      def run
        warn 'Not implemented for MP3s'
      end
    end
  end
end

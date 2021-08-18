# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Does a global find and replace on the given tag.
    #
    class Tagsub < Base
      def run
        find = opts[:'<find>']
        replace = opts[:'<replace>']
        tag = opts[:'<tag>'].to_sym

        orig = info.send(tag)
        new = orig.gsub(Regexp.new(find), replace)

        tagger.tag!(tag => new) unless new == orig
      rescue NoMethodError
        warn "'#{tag}' tag not found."
      end

      def self.help
        <<~EOHELP
          usage: aur tagsub <tag> <find> <replace> <file>...

          Does a GLOBAL find and replace on the given tag in the given file(s).
          <find> can be any Ruby regex (do not wrap it in slashes) and <replace>
          can contain backreferences.
        EOHELP
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'constants'
require_relative 'stdlib/string'

module Aur
  #
  # Methods to construct tags from filenames. The naming, capitalising,
  # bracketing and all of that is just my personal preference.
  #
  class TagFactory
    #
    # Turn a filename-safe string, like 'Blue Bell Knoll' into a tag like
    # 'Blue Bell Knoll'.
    #
    def title(string)
      @in_brackets = false
      raw = string.split('_')
      words = raw.map.with_index { |w, i| handle_word(w, i, raw.count) }
      join_up(words)
    end

    # Artists are handled like titles, but with one completely arbitrary
    # decision: in 'Someone and The Somethings', 'The' is capitalized. So
    # there.
    #
    def artist(string)
      title(string).gsub('and the', 'and The')
    end

    def genre(string)
      raw = string.split
      words = raw.map.with_index { |w, i| smart_capitalize(w, i, raw.count) }
      words.join(' ').gsub(/-[a-z]/, &:upcase)
    end

    private

    # Don't capitalize a word if it's in the NO_CAPS list, but *do* capitalize
    # it if it's the first or last word in a title. String#capitalize will
    # downcase all but the first character, which messes up our brackets
    # handling, hence the logic at the end.
    #
    def smart_capitalize(word, index, len)
      return word if /^(\w\.)+$/.match?(word) # initialisms

      if NO_CAPS.include?(word.downcase) && index.between?(1, len - 2)
        return word.downcase
      end

      return word.capitalize unless /\s/.match?(word)

      word.split(/\s/).map do |w|
        w.start_with?('(') ? w : smart_capitalize(w, 1, len)
      end.join(' ')
    end

    # When creating a title, every word (though a "word" can be multiple
    # actual words separated by one or two dashes) passes through this
    #
    def handle_word(word, index, count)
      if word.match?(/^(\w-)+\w?/)
        word.initials
      elsif word.include?('--')
        handle_long_dash(word, index, count)
      elsif word.include?('-')
        handle_short_dash(word)
      else
        smart_capitalize(word.expand, index, count)
      end
    end

    # A single dash denotes brackets opening or closing.
    #
    def handle_short_dash(word)
      words = word.split('-')
      @in_brackets ? close_brackets(words) : open_brackets(words)
    end

    # I do brackets by treating every segment as a full title. So, I always
    # capitalize the words before and after the brackets, and the first and
    # last words inside them.
    #
    def open_brackets(words)
      @in_brackets = true
      first = words.first.expand(:caps)
      inner = words[1].expand(:caps)

      return "#{first} (#{inner}" if words.size < 3

      final = words.last.expand(:caps)
      inner = words[1..-2].join('-').initials if words.size > 3

      @in_brackets = false
      "#{first} (#{inner}) #{final}"
    end

    def close_brackets(words)
      @in_brackets = false
      "#{words[0].expand(:caps)}) #{words[1].expand(:caps)}"
    end

    # A long dash is a hyphen
    #
    def handle_long_dash(word, index, count)
      ws = word.split('--')
      ws.map { |e| smart_capitalize(e.expand, index, count) }.join('-')
    end

    # Join everything together, and close the brackets if need-be.
    #
    def join_up(words)
      words.flatten.join(' ').tap { |str| str.<< ')' if @in_brackets }
    end
  end
end

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
      strings = string.split('_')

      words = strings.map.with_index do |s, index|
        handle_string(s, index, strings.count)
      end

      join_up(words)
    end

    alias album title

    # Artists are handled like titles, but with one completely arbitrary
    # decision: in 'Someone and The Somethings', 'The' is capitalized. So
    # there.
    #
    def artist(string)
      PRESETS[:artist].fetch(string.to_sym,
                             title(string).gsub('and the ', 'and The '))
    end

    # Strip leading zeroes
    #
    def t_num(num)
      num.to_i.to_s
    end

    def genre(string)
      raw = string.split
      words = raw.map.with_index { |w, i| smart_capitalize(w, i, raw.count) }
      words.join(' ').gsub(/-[a-z]/, &:upcase)
    end

    private

    # Don't capitalize a word if it's in the NO_CAPS list, but *do* capitalize
    # it if it's the first or last word in a title.
    #
    def smart_capitalize(word, index, count)
      if /^(\w\.)+$/.match?(word) # initialisms
        word
      elsif NO_CAPS.include?(word.downcase) && index.between?(1, count - 2)
        word.downcase
      else
        word.capitalize
      end
    end

    # When creating a title, every string (usually a word, but sometimes
    # multiple words separated by one or two dashes) passes through this. It's
    # the inner loop from #title.
    #
    def handle_string(string, index, count)
      if string.match?(/^(\w-)+\w?/)
        string.initials
      elsif string.include?('--')
        handle_long_dash(string, index, count)
      elsif string.include?('-')
        handle_short_dash(string)
      else
        smart_capitalize(string.expand, index, count)
      end
    end

    # A single dash denotes brackets opening or closing.
    #
    def handle_short_dash(string)
      words = string.split('-')
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
    def handle_long_dash(string, index, count)
      words = string.split('--')
      words.map { |w| smart_capitalize(w.expand, index, count) }.join('-')
    end

    # Join everything together, and close the brackets if need-be.
    #
    def join_up(words)
      words.flatten.join(' ').tap { |str| str.<< ')' if @in_brackets }
    end
  end
end

PRESETS = {
  artist: { abba: 'ABBA',
            add_n_to_x: 'Add N to (X)' }
}.freeze

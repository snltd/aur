# frozen_string_literal: true

require_relative 'constants'
require_relative 'words'
require_relative 'stdlib/string'

module Aur
  #
  # Methods to construct tags from filenames. The naming, capitalising,
  # bracketing and all of that is just my personal preference.
  #
  class TagFactory
    def initialize(conf = CONF)
      @words = Aur::Words.new(conf)
    end

    # Turn a filename-safe string, like 'blue_bell_knoll' into a tag like
    # 'Blue Bell Knoll'.
    #
    def title(string)
      @in_brackets = false
      str = string.split('_')
      join_up(str.map.with_index { |s, i| handle_string(s, i, str.count) })
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

    # Don't capitalize a word if it's in the no_caps list, but *do* capitalize
    # it if it's the first or last word in a title.
    #
    # rubocop:disable Lint/DuplicateBranch
    # rubocop:disable Metrics/MethodLength
    def smart_capitalize(word, index, count)
      if word.match?(/^(\w\.)+$/) # initialisms
        word
      elsif @words.no_caps.include?(word.downcase) && index.between?(1,
                                                                     count - 2)
        word.downcase
      elsif @words.all_caps.include?(word.downcase)
        word.upcase
      elsif word.match?(/^[A-Z0-9]+$/)
        word
      else
        word.capitalize
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Lint/DuplicateBranch

    # When creating a title, every string (usually a word, but sometimes
    # multiple words separated by one or two dashes) passes through this. It's
    # the inner loop from #title.
    #
    def handle_string(string, index, count)
      if string.match?(/^([a-z]-)+\w?/)
        string.initials
      elsif string.include?('--')
        handle_long_dash(string)
      elsif string.include?('-')
        handle_short_dash(string, index, count)
      else
        smart_capitalize(string.expand, index, count)
      end
    end

    # A double dash denotes brackets opening or closing.
    #
    def handle_long_dash(string)
      words = string.split('--')
      @in_brackets ? close_brackets(words) : open_brackets(words)
    end

    # I do brackets by treating every segment as a full title. So, I always
    # capitalize the words before and after the brackets, and the first and
    # last words inside them.
    #
    def open_brackets(words)
      @in_brackets = true
      first = words.first.expand(:caps)
      inner = handle_string(words[1], -1, -1)

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

    # A short dash is a hyphen
    #
    def handle_short_dash(string, index, count)
      words = string.split('-')
      words.map { |w| smart_capitalize(w.expand, index, count) }.join('-')
    end

    # Join everything together, and close the brackets if need-be.
    #
    def join_up(words)
      words.flatten.join(' ').tap { |str| str << ')' if @in_brackets }
    end
  end
end

PRESETS = { artist: { add_n_to_x: 'Add N to (X)' } }.freeze

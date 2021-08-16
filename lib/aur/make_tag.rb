# frozen_string_literal: true

require_relative 'constants'
require_relative 'stdlib/string'

module Aur
  #
  # Methods to construct tags from filenames. The naming, capitalising,
  # bracketing and all of that is just my personal preference.
  #
  module MakeTag
    # Turn a filename type name, like 'pet_shop_boys' into a tag type name,
    # like 'Pet Shop Boys'
    #
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    #
    def mk_title(string)
      words = string.split('_')
      in_brackets = false

      new_words = words.map.with_index do |w, i|
        w = w.initials if w.match?(/^(\w-)+\w?/)

        if w.include?('--')
          ws = w.split('--')
          ws.map { |e| smart_capitalize(e.expand, i, words.size) }.join('-')
        elsif w.include?('-')
          ws = w.split('-')
          bw, in_brackets = in_brackets ? close_brackets(ws) : open_brackets(ws)
          bw
        else
          smart_capitalize(w.expand, i, words.size)
        end
      end

      new_words.flatten.join(' ').tap { |str| str.<< ')' if in_brackets }
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # I do brackets by treating every segment as a full title. So, I always
    # capitalize the words before and after the brackets, and the first and
    # last words inside them.
    #
    def open_brackets(words)
      first = words.first.expand(:caps)
      inner = words[1].expand(:caps)

      return ["#{first} (#{inner}", true] if words.size < 3

      final = words.last.expand(:caps)
      inner = words[1..-2].join('-').initials if words.size > 3

      ["#{first} (#{inner}) #{final}", false]
    end

    def close_brackets(words)
      ["#{words[0].expand(:caps)}) #{words[1].expand(:caps)}", false]
    end

    # Don't capitalize a word if it's in the NO_CAPS list, but *do* capitalize
    # it if it's the first or last word in a title. String#capitalize will
    # downcase all but the first character, which messes up our brackets
    # handling, hence the logic at the end.
    #
    def smart_capitalize(word, index, len)
      return word if /^(\w\.)+$/.match?(word) # initialisms

      return word if NO_CAPS.include?(word) && index.between?(1, len - 2)

      return word.capitalize unless /\s/.match?(word)

      word.split(/\s/).map do |w|
        w.start_with?('(') ? w : smart_capitalize(w, 1, len)
      end.join(' ')
    end
  end
end

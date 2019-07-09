# frozen_string_literal: true

require_relative 'constants'

module Aur
  #
  # Methods to construct tags from filenames.
  #
  module TagEdit
    # Turn a filename type name, like 'pet_shop_boys' into a tag
    # type name, like 'Pet Shop Boys'
    #
    def mk_title(string)
      words = string.split('_')
      in_brackets = false

      new_words = words.map.with_index do |w, i|
        w, in_brackets = brackets(w, in_brackets) if w.include?('-')
        w = smart_expand(w)
        smart_capitalize(w, i, words.size)
      end

      new_words.join(' ').tap { |str| str.<< ')' if in_brackets }
    end

    # I think the first word in brackets should always be
    # capitalized. Looks right to me.
    #
    def brackets(word, in_brackets)
      words = word.split('-')
      words[1], inside = bracketize_word(words, in_brackets)
      [words.join(' '), inside]
    end

    # If @words has three elements, return the middle word, in
    # brackets. If it has two elements, open or close brackets
    # before or after the second word, depending on whether or not
    # we are currently in brackets.
    # @param words [Array[String]] a list of words to manipula
    # @param in_brackets [Bool] whether we are currently inside
    #   brackets
    # @return Array [bracketed string, whether we are now inside
    #   brackets]
    #
    def bracketize_word(words, in_brackets)
      if words.size == 3
        ["(#{words[1].capitalize})", false]
      elsif in_brackets
        ["#{words[1]})", false]
      else
        ["(#{words[1].capitalize}", true]
      end
    end

    def smart_expand(word)
      EXPAND.fetch(word.to_sym, word)
    end

    # Don't capitalize a word if it's in the NO_CAPS list, but
    # *do* capitalize it if it's the first or last word in a
    # title. String#capitalize will downcase all but the first
    # character, which messes up our brackets handling, hence the
    # logic in the else clause.
    #
    def smart_capitalize(word, index, len)
      if index.positive? && index < (len - 1) && NO_CAPS.include?(word)
        return word
      end

      return word.capitalize unless word =~ /\s/

      word.split(/\s/).map do |w|
        w.start_with?('(') ? w : smart_capitalize(w, 1, 10)
      end.join(' ')
    end
  end
end

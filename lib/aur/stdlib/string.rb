# frozen_string_literal: true

require 'i18n'
require_relative '../constants'

I18n.available_locales = %i[en]

# Extensions to stdlib String
#
class String
  # The rules for making a filename-safe string are to:
  #   - replace accented characters with basic Latin
  #   - make lowercase
  #   - remove anything that's not a letter, number, underscore or hyphen
  #   - things in brackets have the brackets removed and a dash put in front
  #     and/or behind
  #   - turn all whitespace to a single underscore
  #   - turn '_-_' into a single hyphen
  #   - turn a hyphenated word into word--word
  #
  def to_safe
    I18n.transliterate(String.new(self).force_encoding('utf-8'))
        .downcase
        .gsub('&', 'and')
        .gsub(/(\S)-(\S)/, '\1--\2')
        .gsub(/\s+\(/, '-')
        .gsub(/\)\s+/, '-')
        .gsub(/\s+/, '_')
        .gsub(/[^\w-]/, '')
        .gsub(/_-_/, '-')
  end

  # Expands words like "isnt" to "isn't".
  # @param style [Symbol] :caps forces capitalizition
  #
  def expand(style = nil)
    word = EXPAND.fetch(to_sym, self)
    word = word.capitalize if style == :caps
    word
  end

  # I separate initials with a dash. So y-m-c-a => Y.M.C.A. (including the
  # trailing dot.) Because we also do brackets with a '-', this isn't going to
  # be perfect, but I think it's near enough.
  #
  def initials
    (tr('-', '.') + '.').upcase
  end

  # Checks a string is a safe filename segment
  #
  def safe?
    return true if match?(/^[a-z0-9]$/)

    match?(/^[a-z0-9][\w\-]*[a-z0-9]$/) && squeeze('_') == self
  end

  # Checks a string is 01-99
  #
  def safenum?
    match?(/^[0-9][0-9]$/) && to_i.positive?
  end

  # A somewhat-exclusive version of capitalize.
  #
  def titlecase(previous_word = 'none', force_caps = false)
    if self.match(/^\W/)
      return self.sub(/^(\W+)(.*)/) { |m| "#{$1}#{$2.titlecase('/')}" }
    end

    word = self.gsub(/\W/, '').downcase

    %w[- + /].each do |sep|
      if self.include?(sep)
        return self.split(sep).map { |w| w.titlecase('/') }.join(sep)
      end
    end

    if IGNORE_CASE.include?(word)
      self
    elsif ALL_CAPS.include?(word) || self.match(/^\w\.\w\./)
      upcase
    elsif NO_CAPS.include?(word) && !previous_word.match(/[:\/]$/)
      downcase
    else
      capitalize
    end
  end
end

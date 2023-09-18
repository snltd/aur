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
  #   - things in brackets have the brackets removed and -- put in front
  #     and/or behind
  #   - turn all whitespace to a single underscore
  #   - turn '_-_' into a single hyphen
  #   - turn a hyphenated word into word-word, removing spaces
  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def to_safe
    I18n.transliterate(String.new(self).force_encoding('utf-8'))
        .strip
        .downcase
        .gsub(%r{ [-/+>] }, '--')
        .gsub(/[_-]{3,}/, 'blank')
        .gsub(': ', '--')
        .tr('/', '-')
        .gsub(/\.(\w)/, '-\1')
        .gsub('+', 'plus')
        .gsub('@', 'at')
        .gsub('&', 'and')
        .gsub(/\s+\(/, '--')
        .gsub(/\)\s+/, '--')
        .gsub(/\s+/, '_')
        .gsub(/[^\w-]/, '')
        .gsub('_-_', '-')
        .gsub(/^[_-]+|[-_]+$/, '')
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # Expands words like "isnt" to "isn't".
  # @param style [Symbol] :caps forces capitalizition
  #
  def expand(style = nil)
    word = EXPAND.fetch(to_sym, self)
    word = word.capitalize if style == :caps
    word
  end

  # I separate initials with a dash. So y-m-c-a => Y.M.C.A. (including the
  # trailing dot.)
  #
  def initials
    "#{tr('-', '.')}.".upcase
  end

  # Checks a string is a safe filename segment
  #
  def safe?
    return true if match?(/^[a-z0-9]$/)

    match?(/^[a-z0-9][\w-]*[a-z0-9]$/) && squeeze('_') == self
  end

  # Checks a string is 01-99
  #
  def safenum?
    match?(/^[0-9][0-9]$/) && to_i.positive?
  end

  # A somewhat-exclusive version of capitalize.
  #
  # rubocop:disable Metrics/CyclomaticComplexity
  def titlecase(previous_word = 'none', run_together: false)
    return titlecase_start_with_nonword(self) if /^\W/.match?(self)

    return titlecase_follow_punct(self) if /[:=)]$/.match?(self)

    %w[= - + / :].each do |sep|
      return titlecase_contains_sep(self, sep) if include?(sep)
    end

    return self if titlecase_ignorecase?(self)

    word = gsub(/\W/, '').downcase
    return upcase if titlecase_upcase?(self, word)

    return downcase if titlecase_downcase?(word, run_together, previous_word)

    capitalize
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def compacted
    downcase.gsub(/[^0-9a-z]/, '')
  end

  # Does the string begin with a byte-order marker?
  def bom?
    bytes[0..2] == [239, 187, 191]
  end

  private

  def titlecase_ignorecase?(selfword)
    IGNORE_CASE.include?(selfword.downcase)
  end

  def titlecase_downcase?(word, run_together, previous_word)
    NO_CAPS.include?(word) && (run_together ||
                               !previous_word.match(%r{[:\-/)?!]$}))
  end

  def titlecase_upcase?(selfword, word)
    ALL_CAPS.include?(word) || selfword.match(/^\w\.\w\./) ||
      selfword.match(/^\w,$/)
  end

  def titlecase_start_with_nonword(word)
    word.sub(/^(\W+)(.*)/) do
      "#{Regexp.last_match(1)}#{Regexp.last_match(2).titlecase('/')}"
    end
  end

  def titlecase_follow_punct(word)
    word.sub(/^(\w+)(\W)/) do
      "#{Regexp.last_match(1).titlecase('/')}#{Regexp.last_match(2)}"
    end
  end

  def titlecase_contains_sep(word, sep)
    return unless word.include?(sep)

    word.split(sep).map.with_index do |w, i|
      w.titlecase('/', run_together: i.positive?)
    end.join(sep)
  end
end

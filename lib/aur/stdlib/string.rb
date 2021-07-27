# frozen_string_literal: true

require 'i18n'
I18n.available_locales = %i[en]

# Extensions to stdlib String
#
class String
  # The rules for making a filename-safe string are to:
  #   - replace accented characters with basic Latin
  #   - make lowercase
  #   - remove anything that's not a letter, number, underscore or hyphen
  #   - things in brackets have the brackets removed and a dash put
  #       in front and/or behind
  #   - turn all whitespace to a single underscore
  #   - turn '_-_' into a single hyphen
  #
  def to_safe
    I18n.transliterate(self)
        .downcase
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
end

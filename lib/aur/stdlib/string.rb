# frozen_string_literal: true

require 'i18n'
I18n.available_locales = %i[en]

# Extensions to stdlib
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
end

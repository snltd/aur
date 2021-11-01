# frozen_string_literal: true

module Aur
  #
  # Methods which are useful in multiple places
  #
  module Helpers
    def escaped(word)
      '"' + word.to_s.gsub(/"/, '\"') + '"'
    end
  end
end

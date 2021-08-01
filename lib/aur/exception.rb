# frozen_string_literal: true

module Aur
  #
  # Nothing fancy here. Just named exceptions to make things clearer.
  #
  class Exception
    class InvalidTagName < RuntimeError; end

    class InvalidTagValue < RuntimeError; end
  end
end

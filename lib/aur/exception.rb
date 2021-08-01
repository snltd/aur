# frozen_string_literal: true

module Aur
  #
  # Nothing fancy here. Just named exceptions to make things clearer.
  #
  class Exception
    class FileExists < RuntimeError; end

    class InvalidInput < RuntimeError; end

    class InvalidTagName < RuntimeError; end

    class InvalidTagValue < RuntimeError; end

    class InvalidValue < RuntimeError; end
  end
end
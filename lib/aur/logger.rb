# frozen_string_literal: true

module Aur
  #
  # A mixin for writing messages
  #
  module Logger
    def msg(message)
      return if defined?(opts) && opts[:quiet]

      puts message
    end
  end
end

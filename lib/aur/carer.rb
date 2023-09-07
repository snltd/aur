# frozen_string_literal: true

require_relative './constants'

module Aur
  #
  # Commands such as lint and lintdir throw up errors which we don't care
  # about, or produce false information. This module is called by the
  # command's error handling method, and it looks to see whether the given
  # exception is allowed for the given file.
  #
  class Carer
    attr_reader :ok

    def initialize(conf)
      @ok = conf.fetch(:yes_i_know, {})
    end

    def do_we?(exception, path)
      exc_key = lookup_key(exception)

      return false unless ok.key?(exc_key)

      lookup_values(path).any? { |p| ok[exc_key].include?(p) }
    end

    def lookup_key(exception)
      exception.class.name.split('::').last.to_sym
    end

    def lookup_values(path)
      [path.to_s.sub(%r{^.*/(flac|mp3)/}, '').sub(/\.(mp3|flac)$/, '')]
    end
  end
end
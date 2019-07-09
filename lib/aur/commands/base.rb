# frozen_string_literal: true

require_relative '../stdlib/pathname'
require_relative '../fileinfo'

module Aur
  #
  # Abstract class extended by all commands.
  #
  class Base
    attr_reader :file, :info, :opts, :errs

    # @param file [Pathname]
    # @return [Aur::FileInfo::FileType] where FileType is Flac or
    #   Mp3 or any other supported file type.
    # @raise [NameError] if the info class does not exist
    #
    def initialize(file, opts = {})
      @opts = opts
      @file = file
      @info = Object.const_get(filetype_class).new(file)
      @errs = 0
    end

    # @return [String] name of relevant info class
    # @raise [NameError] if the info class does not exist
    #
    def filetype_class
      format('Aur::FileInfo::%<name>s', name: file.extclass)
    end

    def msg(message)
      return if opts[:quiet]

      puts message
    end
  end
end

# frozen_string_literal: true

require_relative '../stdlib/pathname'
require_relative '../fileinfo'
require_relative '../tagger'
require_relative '../logger'

module Aur
  module Command
    #
    # Abstract class extended by all commands.
    #
    class Base
      include Aur::Logger

      attr_reader :file, :info, :opts, :errs, :tagger

      # @param file [Pathname]
      # @return [Aur::FileInfo::FileType] where FileType is Flac or
      #   Mp3 or any other supported file type.
      # @raise [NameError] if the info class does not exist
      #
      def initialize(file, opts = {})
        @file = file
        @opts = opts
        @info = Object.const_get(class_for(:FileInfo)).new(file)
        @tagger = Object.const_get(class_for(:Tagger)).new(info, opts)
        @errs = 0
      end

      # @return [String] name of relevant info class
      # @raise [NameError] if the info class does not exist
      #
      def class_for(action)
        format('Aur::%<action>s::%<name>s',
               action: action,
               name: file.extclass)
      end
    end
  end
end

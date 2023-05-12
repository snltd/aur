# frozen_string_literal: true

require_relative '../stdlib/pathname'
require_relative '../fileinfo'
require_relative '../tagger'
require_relative '../logger'

module Aur
  module Command
    #
    # Abstract class extended by all commands. Every command operates on a
    # single file. New instances of the Aur::Command classes are created by a
    # loop in Aur::Action#run!
    #
    class Base
      include Aur::Logger

      attr_reader :file, :info, :opts, :errs, :tagger

      # @param file [Pathname]
      # @return [Aur::FileInfo::FileType] where FileType is Flac or Mp3 or any
      #   other supported file type.
      # @raise [NameError] if the info class does not exist
      #
      def initialize(file, opts = {})
        @file = file
        @opts = opts
        @info = setup_info
        @tagger = setup_tagger
        @errs = 0
        load_subclass if @info.respond_to?(:filetype)
      end

      # Separated out for the benefit of transcode, which does not need
      # fileinfo, and would otherwise require classes for arbitrary filetypes.
      #
      def setup_info
        Aur::FileInfo.new(file, opts)
      end

      def setup_tagger
        Aur::Tagger.new(info, opts)
      end

      # Commands can inherit from a module which contains methods specific to
      # a given filetype.
      #
      def load_subclass
        return unless Aur::Command.const_defined?(filetype_module)

        extend Object.const_get("Aur::Command::#{filetype_module}")
      end

      # Looks up the module which a command class can use to handle a specific
      # filetype. Sometimes info isn't actualy a FileInfo object.
      #
      def filetype_module
        self.class.name.split('::').last + info.filetype.capitalize
      end

      # Override this if you don't want an error summary
      #
      def no_error_report
        false
      end
    end
  end
end

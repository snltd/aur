# frozen_string_literal: true

require_relative 'constants'

module Aur
  #
  # Command dispatcher. When given an @action, the class will load a
  # libary filed called 'action.rb'. This must contain a Generic
  # class or a class for each supported filetype. Said classes
  # contain methods which can perform the given action on all file
  # types which may occur in @flist.
  #
  class Command
    attr_reader :flist, :action, :errs

    # @param action [Symbol] the action to take.
    # @param flist [Array[Pathname]] list of files to which the
    #   action must be applied.
    #
    def initialize(action, flist)
      load_library(action.to_s)
      @flist = screen_flist(flist.map { |f| Pathname.new(f) })
      @action = action.capitalize
      @errs = []
    end

    def run!
      flist.each { |f| run_file(f) }
    end

    private

    # Some operations present the same interface regardless of file
    # type. Others do not. This dispatcher calls the "special" class
    # (e.g. Flac) if there is one, and the generic class (Generic)
    # if not.
    #
    # @param file [Pathname] file which needs action applied
    #
    # rubocop:disable Metrics/MethodLength
    def run_file(file)
      k_special = special_class(file)
      k_generic = generic_class(file)

      if k_special.respond_to?(:run)
        k_special.run
      elsif k_generic.respond_to?(:run)
        k_generic.run
      else
        puts "Don't know what to do with #{file}."
      end
    rescue FlacInfoReadError
      puts "ERROR: cannot read FLAC info for '#{file}'."
      @errs.<< file
    end
    # rubocop:enable Metrics/MethodLength

    # @param libfile [String]
    #
    def load_library(libfile)
      require_relative(File.join('commands', libfile))
    rescue LoadError => e
      p e
      abort "ERROR: '#{libfile}' command is not implemented."
    end

    # @param flist [Array[Pathname]]
    # @return [Array[Pathname]]
    #
    def screen_flist(flist)
      flist.select do |f|
        f.file? && SUPPORTED_TYPES.include?(f.extname.delete('.'))
      end
    end

    # @param file [Pathname] file which needs action applied
    # @return [Aur::Module::Class]
    #
    def generic_class(file)
      create_class(format('Aur::%<action>s::Generic', action: action), file)
    end

    # @param file [Pathname] file which needs action applied
    # @return [Aur::Module::Class]
    #
    def special_class(file)
      create_class(format('Aur::%<action>s::%<file_type>s',
                          action: action, file_type: file.extclass), file)
    end

    # @param file [Pathname] file which needs action applied
    # @return [Aur::Module::Class, nil]
    #
    def create_class(name, file)
      return nil unless Object.const_defined?(name)

      Object.const_get(name).new(file)
    end
  end
end

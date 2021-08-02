# frozen_string_literal: true

require_relative 'exception'
require_relative 'constants'
require_relative 'stdlib/pathname'

module Aur
  #
  # Command dispatcher. When given an @action, the class will load a
  # file called 'commands/action.rb', and from it load a class called
  # 'Aur::Command:Action', passing @opts to the initializer. That class
  # contains a #run method, which runs the action.
  #
  # action.rb can optionally load files from commands/filetype/action.rb to
  # deal with different target filetypes.
  #
  class Action
    attr_reader :flist, :action, :errs, :opts

    # @param action [Symbol] the action to take.
    # @param flist [Array[Pathname]] list of files to which the
    #   action must be applied.
    #
    def initialize(action, flist, opts = {})
      @flist = screen_flist(flist.map { |f| Pathname.new(f) })
      load_library(action.to_s)
      @opts = opts
      @action = action.capitalize
      @errs = []
    end

    def run!
      warn 'No valid files supplied.' if flist.empty?

      flist.each { |f| run_command(f) }
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
    def run_command(file)
      klass = action_class(file)

      if klass.respond_to?(special_method(file))
        klass.send(special_method(file))
      elsif klass.respond_to?(:run)
        klass.run
      else
        raise Aur::Exception::UnsupportedFiletype
      end
    rescue FlacInfoReadError => e
      return if action == :Name2tag

      warn "ERROR: cannot read FLAC info for '#{file}'."
      puts e
      @errs.<< file
      # rescue StandardError => e
      # warn "Error handling
      # puts e
      # @errs.<< file
    rescue Aur::Exception::InvalidTagValue => e
      warn "'#{e}' is an invalid value."
    rescue Aur::Exception::InvalidTagName => e
      warn "'#{e}' is not a valid tag name."
    end
    # rubocop:enable Metrics/MethodLength

    def special_method(file)
      "run_#{file.extclass.downcase}".to_sym
    end

    # @param libfile [String]
    #
    def load_library(libfile)
      require_relative(File.join('commands', libfile))
    rescue LoadError => e
      puts e
      abort "ERROR: '#{libfile}' command is not implemented."
    end

    # Given a list of files, returns a list of files which aur knows how to
    # process.
    # @param flist [Array[Pathname]]
    # @return [Array[Pathname]]
    #
    def screen_flist(flist)
      flist.select do |f|
        f.file? && SUPPORTED_TYPES.include?(f.extname.delete('.'))
      end
    end

    # @param file [Pathname] file which needs action applied
    # @return [Aur::Command::*] instance of class ready to deal with file
    #
    def action_class(file)
      create_class(format('Aur::Command::%<action>s', action: action), file)
    end

    # @param file [Pathname] file which needs action applied
    # @return [Aur::Module::Class, nil]
    #
    def create_class(name, file)
      return nil unless Object.const_defined?(name)

      Object.const_get(name).new(file, opts)
    end
  end
end

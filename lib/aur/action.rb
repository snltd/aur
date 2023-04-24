# frozen_string_literal: true

require 'flacinfo'
require 'colorize'
require 'mp3info'
require_relative 'exception'
require_relative 'constants'
require_relative 'stdlib/pathname'
require_relative 'stdlib/array'

module Aur
  #
  # Command dispatcher. When given an @action, the class will load a
  # file called 'commands/action.rb', and from it load a class called
  # 'Aur::Command::Action', passing @opts to the initializer. That class
  # contains a #run method, which runs the action.
  #
  # action.rb can optionally load files from commands/filetype/action.rb to
  # deal with different target filetypes.
  #
  class Action
    attr_reader :flist, :errs, :opts, :klass

    # @param action [Symbol] the action to take.
    # @param flist [Array[Pathname]] list of files to which the
    #   action must be applied.
    #
    # rubocop:disable Metrics/MethodLength
    def initialize(action, flist, opts = {})
      @opts = opts
      @errs = []

      require_action(action)

      @klass = action_class(action)

      @flist = if klass.respond_to?(:screen_flist)
                 klass.screen_flist(flist.to_paths, opts)
               else
                 screen_flist(flist.to_paths)
               end
    rescue Errno::ENOENT
      abort 'File not found.'
    end
    # rubocop:enable Metrics/MethodLength

    def run!
      warn 'No valid files supplied.' if flist.empty?

      flist.each { |f| run_command(f) }
    end

    def no_error_report
      klass.no_error_report
    rescue NoMethodError
      false
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
    # rubocop:disable Metrics/AbcSize
    def run_command(file)
      action_class = @klass.new(file, opts)
      return action_class.run if action_class.respond_to?(:run)

      raise Aur::Exception::UnsupportedFiletype
    rescue Aur::Exception::Collector => e
      @errs << e.to_s
    rescue FlacInfoWriteError => e
      abort "#{file} write error: '#{e}'. Re-encode?".red.bold
    rescue FlacInfoReadError,
           Mp3InfoEOFError,
           Aur::Exception::FailedOperation => e
      if action_class.respond_to?(:handle_err)
        return action_class.handle_err(file, e)
      end

      warn "ERROR: cannot process '#{file}'.".bold
      @errs << file.to_s
    rescue Aur::Exception::InvalidTagValue => e
      die "#{file}: #{e}"
    rescue Aur::Exception::InvalidTagName => e
      die "#{file}: #{e} (invalid tag)"
    rescue Aur::Exception::InvalidInput => e
      die "Bad input: #{e}"
    rescue Errno::ENOENT => e
      die "File not found: #{e}".bold.red
    rescue Errno::ENOTDIR
      die 'Argument must be a directory.'
    rescue StandardError => e
      warn "ERROR: Unhandled error on #{file}".red.bold
      puts e
      exit 2
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def die(message)
      warn "ERROR: #{message}"
      exit 1
    end

    # @param libfile [String]
    #
    def require_action(action)
      require_relative(File.join('commands', action.to_s))
    rescue LoadError
      die "'#{libfile}' command is not implemented."
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

    # @return [Aur::Command::*] instance of class ready to be instantiated
    #
    def action_class(action)
      Object.const_get(format('Aur::Command::%<action>s',
                              action: action.to_s.capitalize))
    end
  end
end

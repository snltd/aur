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
  # 'Aur::Command:Action', passing @opts to the initializer. That class
  # contains a #run method, which runs the action.
  #
  # action.rb can optionally load files from commands/filetype/action.rb to
  # deal with different target filetypes.
  #
  class Action
    attr_reader :flist, :action, :errs, :opts, :klass

    # @param action [Symbol] the action to take.
    # @param flist [Array[Pathname]] list of files to which the
    #   action must be applied.
    #
    # rubocop:disable Metrics/MethodLength
    def initialize(action, flist, opts = {})
      @action = action.capitalize
      @opts = opts
      @errs = []

      action_handler = "handle_#{action}".to_sym

      if respond_to?(action_handler)
        send(action_handler)
      else
        @flist = screen_flist(flist.to_paths)
        load_library(action.to_s)
      end
    rescue Errno::ENOENT
      abort 'File not found.'
    end
    # rubocop:enable Metrics/MethodLength

    # Special handler for lintdir command, necessary because it operates on
    # directories, and everything up to now operates on files. At the moment
    # it's unique in that it's different. If we get another couple of oddballs
    # we'll break them all out into something cleaner.
    #
    def handle_lintdir
      dirs = opts[:'<directory>'].to_paths

      @flist = opts[:recursive] ? recursive_dir_list(dirs) : dirs

      load_library('lintdir')
    end

    def handle_ls
      dirs = opts[:'<directory>'].to_paths

      dirs = [Pathname.pwd] if dirs.empty?

      @flist = opts[:recursive] ? recursive_dir_list(dirs) : dirs

      load_library('ls')
    end

    def handle_help
      require_relative 'commands/help'
      Aur::Command::Help.new(opts[:'<command>'])
      exit
    end

    def handle_artfix
      @flist = opts[:'<directory>'].to_paths
      load_library('artfix')
    end

    def handle_mp3dir
      @flist = opts[:'<directory>'].to_paths
      load_library('mp3dir')
    end

    def handle_syncflac
      @flist = [Pathname.new('/storage')]
      load_library('syncflac')
    end

    def handle_wantflac
      @flist = [Pathname.new('/storage')]
      load_library('wantflac')
    end

    # Blows up an array of directories to an array of those directories and
    # all the directories under them, uniquely sorted.
    # @param roots [Array[Pathname]]
    # @return [Array[Pathname]] all directories under all roots
    #
    def recursive_dir_list(dirs)
      (dirs + dirs.map do |d|
        Pathname.glob("#{d}/**/*/")
      end.flatten).map(&:realpath).uniq.sort
    end

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
      @klass = action_class(file)
      return klass.run if klass.respond_to?(:run)

      raise Aur::Exception::UnsupportedFiletype
    rescue Aur::Exception::Collector => e
      @errs << e.to_s
    rescue FlacInfoWriteError => e
      abort "#{file} write error: '#{e}'. Re-encode?".red.bold
    rescue FlacInfoReadError,
           Mp3InfoEOFError,
           Aur::Exception::FailedOperation => e
      return klass.handle_err(file, e) if klass.respond_to?(:handle_err)

      warn "ERROR: cannot process '#{file}'.".bold
      @errs.<< file.to_s
    rescue Aur::Exception::InvalidTagValue => e
      die "'#{e}' is an invalid value."
    rescue Aur::Exception::InvalidTagName => e
      die "'#{e}' is not a valid tag name."
    rescue Aur::Exception::InvalidInput => e
      die "Bad input: #{e}"
    rescue Errno::ENOENT => e
      die "File not found: #{e}".bold.red
    rescue Errno::ENOTDIR
      die 'Argument must be a directory.'
    rescue StandardError => e
      warn "ERROR: Unhandled error on #{file}".red.bold
      pp e
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
    def load_library(libfile)
      require_relative(File.join('commands', libfile))
    rescue LoadError
      die "'#{libfile}' command is not implemented."
    end

    # Given a list of files, returns a list of files which aur knows how to
    # process.
    # @param flist [Array[Pathname]]
    # @return [Array[Pathname]]
    #
    def screen_flist(flist)
      return flist if action == :Transcode # ffmpeg can transcode anything

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

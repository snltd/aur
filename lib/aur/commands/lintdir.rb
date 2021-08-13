# frozen_string_literal: true

require 'pathname'
require_relative 'base'
require_relative '../constants'
require_relative '../exception'

module Aur
  module Command
    #
    # Examines directories, checking their contents abide by our standards.
    # This Command doesn't fit with the rest of the module because it does not
    # extend the Base class.
    #
    class Lintdir
      def initialize(dir = nil, opts = {})
        @dir = dir
        @opts = opts
      end

      def run
        return if @dir.children.all?(&:directory?)

        lint(@dir)
      rescue Errno::ENOTDIR
        true
      rescue Errno::ENOENT
        warn "'#{@dir}' not found."
        false
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def lint(dir)
        files = dir.children.select(&:file?)
        correctly_named?(dir)
        no_junk?(files)
        all_same_filetype?(files)
        expected_files?(files)
        sequential_files?(files)
        cover_art?(files)
      rescue Aur::Exception::LintDirBadName
        err(dir, 'Invalid directory name')
      rescue Aur::Exception::LintDirBadFile => e
        err(dir, "Bad file(s)\n  #{e}")
      rescue Aur::Exception::LintDirMixedFiles
        err(dir, 'Different file types')
      rescue Aur::Exception::LintDirBadFileCount => e
        err(dir, "Missing file(s) (#{e})")
      rescue Aur::Exception::LintDirUnsequencedFile => e
        err(dir, "Missing track #{e}")
      rescue Aur::Exception::LintDirMissingCoverArt
        err(dir, 'Missing cover art')
      rescue Aur::Exception::LintDirUnwantedCoverArt
        err(dir, 'Unwanted cover art')
      rescue StandardError => e
        warn "Bombed in #{dir}"
        pp e
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def err(dir, msg)
        warn(format('%-110<dir>s    %<msg>s', dir: dir, msg: msg))
      end

      # A "proper" album directory should be of the form
      # 'artist_name.album_name', but these can have sub-directories. So, if
      # we find content in an incorrectly named directory, we examine the
      # parent, and return true if that looks okay.
      #
      def correctly_named?(dir, on_retry = false)
        name = dir.basename.to_s

        return true if name.match(/^[a-z0-9][a-z\-._0-9]+[a-z0-9]$/) &&
                       name.split('.').size == 2 && !name.start_with?('the_')

        return correctly_named?(dir.parent, true) if on_retry == false

        raise Aur::Exception::LintDirBadName
      end

      # There should only be audio files and possibly cover art, and possibly
      # a directory or two.
      #
      def no_junk?(files)
        uns = files - supported(files)
        uns.reject! { |f| f.basename.to_s.match?(/^front.(png|jpg)$/) }

        return true if uns.empty? || uns.all?(&:directory?)

        raise Aur::Exception::LintDirBadFile, uns.sort.join("\n  ")
      end

      # The number of audio files in the directory should be the same as the
      # highest track number, and track numbers should run from 01 to that
      # highest number, with no breaks. This can get messed up by hidden
      # tracks.
      #
      def expected_files?(files)
        files = supported(files)
        hn = highest_number(files)

        return true if hn == files.size

        raise Aur::Exception::LintDirBadFileCount, "#{files.size}/#{hn}"
      end

      def sequential_files?(files)
        1.upto(highest_number(files)) do |n|
          index = format('%02d', n)

          unless files.any? { |f| f.basename.to_s.start_with?("#{index}.") }
            raise Aur::Exception::LintDirUnsequencedFile, index
          end
        end

        true
      end

      # Ignoring cover art, everything should be either an MP3 or a FLAC.
      #
      def all_same_filetype?(files)
        return true if supported(files).map(&:extname).uniq.size <= 1

        raise Aur::Exception::LintDirMixedFiles
      end

      # Do we have a front.jpg or front.png?
      #
      def cover_in(files)
        fnames = files.map { |f| f.basename.to_s }
        fnames.include?('front.jpg') || fnames.include?('front.png')
      end

      # I want cover art for FLACs, but not MP3s.
      #
      def cover_art?(files)
        case files.first.extname
        when '.flac'
          raise Aur::Exception::LintDirMissingCoverArt unless cover_in(files)
        when '.mp3'
          raise Aur::Exception::LintDirUnwantedCoverArt if cover_in(files)
        end

        true
      end

      # @param [Array[Pathname]] returns the highest track number in the given
      #   files, derived from their names
      # @return [Int]
      #
      def highest_number(files)
        files = supported(files)

        return 0 if files.empty?

        filenum(files.max)
      end

      def filenum(file)
        file.basename.to_s.split('.').first.to_i
      end

      # Filter a file list for supported audio types with the correct suffix.
      # @param files [Array[Pathname]]
      # @return [Array[Pathname]] input, filtered to supported audio types
      #
      def supported(files)
        files.select { |f| SUPPORTED_TYPES.include?(f.extname.delete('.')) }
      end

      def self.help
        <<~EOHELP
          usage: aur lintdir [-r] <directory>...

          Checks a directory, ensuring that:
            - the directory name is correctly formatted
            - all audio files are of the same type
            - audio files are numbered sequentially
            - the correct number of audio files are present
            - no non-audio files exist (except cover art)

          The contents of files are not examined. For that, use the 'lint'
          command. Nothing on-disk is changed.
        EOHELP
      end
    end
  end
end

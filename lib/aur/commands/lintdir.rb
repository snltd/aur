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
        lint(@dir)
      rescue Errno::ENOTDIR
        true
      end

      # rubocop:disable Metrics/MethodLength
      def lint(dir)
        files = dir.children.select(&:file?)
        correctly_named?(dir)
        no_junk?(files)
        all_same_filetype?(files)
        sequential_files?(files)
        cover_art?(files)
      rescue Aur::Exception::LintDirBadName
        puts "Invalid directory name: #{dir}"
      rescue Aur::Exception::LintDirBadFile => e
        puts "Bad file(s) in #{dir}: #{e}"
      rescue Aur::Exception::LintDirMixedFiles
        puts "Different filetypes found in #{dir}"
      rescue Aur::Exception::LintDirBadFileCount => e
        puts "Misssing files in #{dir}: #{e}"
      end
      # rubocop:enable Metrics/MethodLength

      # A directory should be either 'disc_n' where n is an integer, or
      # 'artist_name.album_name', or something_disc.
      #
      def correctly_named?(dir)
        name = dir.basename.to_s

        return true if name.match(/^disc_[0-9]$/) || name.match(/_disc$/)

        return true if name.match(/^[a-z0-9][a-z\-._0-9]+[a-z0-9]$/) &&
                       name.split('.').size == 2 && !name.start_with?('the_')

        raise Aur::Exception::LintDirBadName
      end

      # There should only be audio files and possibly cover art, and possibly
      # a directory or two.
      #
      def no_junk?(files)
        uns = files - supported(files)
        uns.reject! { |f| f.basename.to_s.match?(/^front.(png|jpg)$/) }

        return true if uns.empty? || uns.all?(&:directory?)

        raise Aur::Exception::LintDirBadFile, uns.join(', ')
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

        raise Aur::Exception::LintDirBadFileCount,
              "expected #{hn}, got #{files.size}"
      end

      def sequential_files?(files)
        1.upto(highest_number(files)) do |n|
          index = format('%02d', n)

          unless files.any? { |f| f.basename.to_s.start_with?("#{index}.") }
            raise Aur::Exception::LintDirUnsequencedFile
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

      # I have cover art for FLACs, but not MP3. This is a bit hacky
      #
      def cover_art?(files)
        return true if files.first.extname == '.flac' && cover_in(files)

        return true unless cover_in(files)

        raise Aur::Exception::LintDirBadFile
      end

      # @param [Array[Pathname]] returns the highest track number in the given
      #   files, derived from their names
      # @return [Int]
      #
      def highest_number(files)
        return 0 if files.empty?

        filenum(supported(files).max)
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
          command.
        EOHELP
      end
    end
  end
end
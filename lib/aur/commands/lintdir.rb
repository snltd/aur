# frozen_string_literal: true

require 'fastimage'
require 'pathname'
require_relative '../constants'
require_relative '../exception'
require_relative '../fileinfo'
require_relative '../helpers'

module Aur
  module Command
    #
    # Examines directories, checking their contents abide by our standards.
    # This Command doesn't fit with the rest of the module because it does not
    # extend the Base class.
    #
    # rubocop:disable Metrics/ClassLength
    class Lintdir
      def initialize(dir = nil, opts = {})
        @dir = dir&.expand_path
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
        no_junk?(files)
        return true if supported(files).empty?

        correctly_named?(dir)
        all_same_filetype?(files)
        expected_files?(files)
        sequential_files?(files)
        cover_art?(files)
        cover_art_looks_ok?(arty(files))
        tags = all_tags(files)
        all_same_album?(tags)
        all_same_genre?(tags)
        all_same_year?(tags)
        all_same_artist?(tags) unless various_artists?(dir)
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
      rescue Aur::Exception::LintDirCoverArtMissing
        err(dir, 'Missing cover art')
      rescue Aur::Exception::LintDirCoverArtUnwanted
        err(dir, 'Unwanted cover art')
      rescue Aur::Exception::LintDirInconsistentTags => e
        err(dir, "Inconsistent #{e} tag")
      rescue Aur::Exception::LintDirCoverArtTooBig,
             Aur::Exception::LintDirCoverArtTooSmall,
             Aur::Exception::LintDirCoverArtNotSquare => e
        err(dir, "Unsuitable image size: #{e}")
      rescue StandardError => e
        warn "Unhandled exception #{e} in #{dir}"
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def err(dir, msg)
        msglen = msg.length + 6
        warn(format("%-#{TW - msglen}<dir>s    %<msg>s", dir: dir, msg: msg))
      end

      # A "proper" album directory should be of the form
      # 'artist_name.album_name', but these can have sub-directories. So, if
      # we find content in an incorrectly named directory, we examine the
      # parent, and return true if that looks okay.
      #
      def correctly_named?(dir, on_retry: false)
        name = dir.basename.to_s

        return true if name.match(/^[a-z0-9][a-z\-._0-9]+[a-z0-9]$/) &&
                       name.split('.').size == 2 && !name.start_with?('the_')

        return correctly_named?(dir.parent, on_retry: true) if on_retry == false

        raise Aur::Exception::LintDirBadName
      end

      # There should only be audio files and possibly cover art, and possibly
      # a directory or two.
      #
      def no_junk?(files)
        uns = files - supported(files)
        uns.reject! { |f| f.basename.to_s == 'front.jpg' }

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

      # Everything should have the same album tag
      #
      def all_same_album?(tags)
        all_same_tag?(tags, :album)
      end

      # Everything should have the same year tag
      #
      def all_same_year?(tags)
        all_same_tag?(tags, :year)
      end

      # And probably of the same genre. (Who cares, really, about the genre
      # tag anyway?)
      #
      def all_same_genre?(tags)
        all_same_tag?(tags, :genre)
      end

      # Hmmm. Problems with "featuring" and collaborations. This will need
      # some thought. Let's see how it plays in everyday usage.
      #
      def all_same_artist?(tags)
        all_same_tag?(tags, :artist)
      end

      # Ignoring cover art, everything should be either an MP3 or a FLAC.
      #
      def all_same_filetype?(files)
        return true if supported(files).map(&:extname).uniq.size <= 1

        raise Aur::Exception::LintDirMixedFiles
      end

      # Do we have a front.jpg?
      #
      def cover_in(files)
        fnames = files.map { |f| f.basename.to_s }
        fnames.include?('front.jpg')
      end

      # I want cover art for FLACs, but not MP3s.
      #
      def cover_art?(files)
        case files.first.extname
        when '.flac'
          raise Aur::Exception::LintDirCoverArtMissing unless cover_in(files)
        when '.mp3'
          raise Aur::Exception::LintDirCoverArtUnwanted if cover_in(files)
        end

        true
      end

      def square_enough?(x_dim, y_dim)
        (1 - (x_dim / y_dim.to_f)).abs < ARTWORK_RATIO
      end

      # rubocop:disable Metrics/MethodLength
      def cover_art_looks_ok?(files)
        raise Aur::Exception::LintDirCoverArtUnwanted if files.size > 1

        files.each do |f|
          x, y = FastImage.size(f)

          unless square_enough?(x, y)
            raise Aur::Exception::LintDirCoverArtNotSquare, "#{x} x #{y}"
          end

          if x > ARTWORK_MAX
            raise Aur::Exception::LintDirCoverArtTooBig, "#{x} x #{y}"
          end

          if x < ARTWORK_MIN
            raise Aur::Exception::LintDirCoverArtTooSmall, "#{x} x #{y}"
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

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

      def arty(files)
        ok_names = %w[front.jpg front.png].freeze

        files.select { |f| ok_names.include?(f.basename.to_s) }
      end

      def various_artists?(dir)
        dirname = dir.basename.to_s

        dirname = dir.parent.basename.to_s if dirname.match?(/disc_[0-9]+/)

        dirname.start_with?('various.') || dirname.include?('--')
      end

      # Filter a file list for supported audio types with the correct suffix.
      # @param files [Array[Pathname]]
      # @return [Array[Pathname]] input, filtered to supported audio types
      #
      def supported(files)
        files.select { |f| SUPPORTED_TYPES.include?(f.extname.delete('.')) }
      end

      def self.screen_flist(_flist, opts)
        dirs = opts[:'<directory>'].to_paths
        opts[:recursive] ? Aur::Helpers.recursive_dir_list(dirs) : dirs
      end

      def self.help
        <<~EOHELP
          usage: aur lintdir [-r] <directory>...

          Checks a directory, ensuring that:
            - the directory name is correctly formatted
            - all audio files are of the same type
            - audio files are numbered sequentially
            - tags which should be the same, are
            - the correct number of audio files are present
            - no non-audio files exist (except cover art)

          The contents of files are not examined. For that, use the 'lint'
          command. Nothing on-disk is changed.
        EOHELP
      end

      private

      # Get the relevant tags for all files.
      #
      def all_tags(files)
        supported(files).map { |f| Aur::FileInfo.new(f).our_tags }
      end

      # @return [True] if all values of 'tag' in 'tags' are the same
      # @raise [LintDirInconsistentTags] if not
      #
      def all_same_tag?(tags, tag)
        return true if tags.map { |t| t[tag] }.uniq.size == 1

        raise Aur::Exception::LintDirInconsistentTags, tag
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end

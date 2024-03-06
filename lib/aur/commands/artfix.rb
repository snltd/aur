# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative 'mixins/cover_art'
require_relative '../helpers'
require_relative '../exception'

module Aur
  module Command
    #
    # If the given directory contains an image, ensure it is correctly named
    # and sized.
    #
    class Artfix
      include Aur::Mixin::CoverArt

      attr_reader :dir, :opts

      SUFFIXES = %w[.jpg .jpeg].freeze
      OK_NAME = 'front.jpg'

      def initialize(dir = nil, opts = {})
        @dir = dir
        @opts = opts
      end

      def run
        rename
        resize
      end

      # If there are multiple files, this will rename all of them, so you'll
      # end up with one. This is a legacy of when we allowed PNGs, but it's
      # probably fine.
      #
      def rename
        image_files(dir).sort.each do |f|
          puts "renaming #{f} -> #{OK_NAME}"
          f.rename(cover_file)
        end
      end

      # If front.jpg is too big, but is square, resize it by shelling out to
      # ImageMagick. If it is not square, symlink it to an `artfix/` directory
      # in the user's $HOME.
      #
      def resize
        return unless cover_file.exist?

        cover_art_looks_ok?(cover_file)
      rescue Aur::Exception::LintDirCoverArtNotSquare,
             Aur::Exception::LintDirCoverArtTooSmall
        link_artwork(cover_file)
      rescue Aur::Exception::LintDirCoverArtTooBig
        resize_artwork(cover_file)
      end

      def link_artwork(file)
        linkdir = opts.fetch(:linkdir, ARTWORK_DIR)

        puts "linking #{file} to #{linkdir}"
        mk_work_dir(linkdir)
        FileUtils.symlink(file.realpath, linkdir.join(mk_link_target(file)))
      end

      def mk_link_target(file)
        @dir.realpath.join(file).to_s[1..].tr('/', '-')
      end

      def resize_artwork(file)
        puts "resizing #{file}"

        res = system(rescale_cmd(file))

        abort "failed to resize #{file}" unless res
      end

      def new_name(old_name)
        return old_name.dirname.join('front.jpg') if right_filetype?(old_name)

        raise Aur::Exception::UnsupportedFiletype
      end

      # @param dir [Pathname]
      # @return [Array[Pathname]] JPEGs in @dir not called front.jpg
      #
      def image_files(dir)
        dir.children
           .select(&:file?)
           .select { |f| right_filetype?(f) }
           .reject { |f| f.basename.to_s == OK_NAME }
      end

      def right_filetype?(file)
        SUFFIXES.include?(file.extname.downcase)
      end

      def self.screen_flist(_flist, opts)
        dirs = opts[:'<directory>'].to_paths
        opts[:recursive] ? Aur::Helpers.recursive_dir_list(dirs) : dirs
      end

      def self.help
        <<~EOHELP
          usage: aur artfix <directory>...

          Looks at image files in <directory>, renaming JPEGs to 'front.jpg',
          and scaling them correctly if they are square, but too big.
          Non-square images are symlinked to #{ARTWORK_DIR} for manual fixing.
        EOHELP
      end

      private

      def cover_file
        @dir.join(OK_NAME)
      end

      def mk_work_dir(dir)
        return if dir.exist?

        FileUtils.mkdir_p(dir)
      end

      def rescale_cmd(file)
        "#{BIN[:convert]} #{file} -scale #{ARTWORK_DEF}x#{ARTWORK_DEF} " \
          "-quality 80 #{file}"
      end
    end
  end
end

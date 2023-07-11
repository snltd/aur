# frozen_string_literal: true

require 'pathname'
require_relative '../exception'

module Aur
  module Command
    #
    # If the given directory contains an image, ensure it is correctly named.
    #
    class Artfix
      attr_reader :dir, :opts

      SUFFIXES = %w[.jpg .jpeg].freeze
      OK_NAME = 'front.jpg'

      def initialize(dir = nil, opts = {})
        @dir = dir
        @opts = opts
      end

      def run
        rename
      end

      def rename
        candidates(dir).sort.each do |f|
          new = new_name(f)
          puts "renaming #{f} -> #{new.basename}"
          f.rename(new) unless opts[:noop]
        end
      end

      def new_name(old_name)
        return old_name.dirname.join('front.jpg') if right_filetype?(old_name)

        raise Aur::Exception::UnsupportedFiletype
      end

      # @param dir [String,Pathname]
      # @return [Pathname] the first JPEG file in @dir not called front.jpg
      #
      def candidates(dir)
        Pathname.glob("#{dir}/**/*").select do |f|
          right_filetype?(f) && f.file? && f.basename.to_s != OK_NAME
        end
      end

      def right_filetype?(file)
        SUFFIXES.include?(file.extname.downcase)
      end

      def self.screen_flist(_flist, opts)
        opts[:'<directory>'].to_paths
      end

      def self.help
        <<~EOHELP
          usage: aur artfix <directory>...

          Recurses down from <directory>, finding any incorrectly named image
          and renaming it to 'front.jpg' or 'front.png'.
        EOHELP
      end
    end
  end
end

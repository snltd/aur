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

      SUFFIXES = %w[.jpg .jpeg .png].freeze
      OK_NAMES = %w[front.jpg front.png].freeze

      def initialize(dir = nil, opts = {})
        @dir = dir
        @opts = opts
      end

      def run
        candidates(dir).sort.each do |f|
          new = new_name(f)
          puts "renaming #{f} -> #{new.basename}"
          f.rename(new) unless opts[:noop]
        end
      end

      def new_name(old_name)
        dir = old_name.dirname

        case old_name.extname.downcase
        when '.jpg', '.jpeg'
          dir + 'front.jpg'
        when '.png'
          dir + 'front.png'
        else
          raise Aur::Exception::UnsupportedFiletype
        end
      end

      # @param dir [String,Pathname]
      # @return [Array[Pathname]] all JPEGs or PNGs under @dir not called
      # front.jpg or front.png
      #
      def candidates(dir)
        Pathname.glob("#{dir}/**/*").select do |f|
          SUFFIXES.include?(f.extname.downcase) && f.file? &&
            !OK_NAMES.include?(f.basename.to_s)
        end
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

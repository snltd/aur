# frozen_string_literal: true

require 'pathname'
#require_relative 'base'
#require_relative '../constants'
#require_relative '../exception'

module Aur
  module Command
    #
    # If the given directory contains an image, ensure it is correctly named.
    #
    class Artfix
      def initialize(dir = nil, opts = {})
        @dir = dir
        @opts = opts
      end

      def run
        candidates(@dir).each do |f|
          puts "renaming #{f}"
          rename(f)
        end
      end

      # @param dir [String,Pathname]
      # @return [Array[Pathname]] all JPEGs or PNGs under @dir not called
      # front.jpg or front.png
      #
      def candidates(dir)
        Pathname.glob("#{dir}/**/*").select do |f|
          %w[.png .jpg].include?(f.extname.downcase)
        end.reject { |f| %w[front.jpg front.png].include?(f.basename.to_s) }
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

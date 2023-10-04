# frozen_string_literal: true

require 'fastimage'
require_relative '../../constants'

module Aur
  module Mixin
    #
    # Used for lintdir and artfix
    #
    module CoverArt
      def arty(files)
        files.find { |f| f.basename.to_s == 'front.jpg' }
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def cover_art_looks_ok?(file)
        return false unless file&.exist?

        x, y = FastImage.size(file)
        dims = "#{x} x #{y}"

        raise Aur::Exception::ArtfixNilSize if x.nil? || y.nil?

        raise Aur::Exception::LintDirCoverArtNotSquare, dims if x != y

        raise Aur::Exception::LintDirCoverArtTooBig, dims if x > ARTWORK_DEF

        raise Aur::Exception::LintDirCoverArtTooSmall, dims if x < ARTWORK_MIN

        true
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end

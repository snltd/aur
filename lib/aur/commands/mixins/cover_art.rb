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
        return unless file&.exist?

        x, y = FastImage.size(file)

        raise Aur::Exception::ArtfixNilSize if x.nil? || y.nil?

        raise Aur::Exception::LintDirCoverArtNotSquare if x != y

        raise Aur::Exception::LintDirCoverArtTooBig if x > ARTWORK_DEF

        if x < ARTWORK_MIN
          raise Aur::Exception::LintDirCoverArtTooSmall, "#{x} x #{y}"
        end

        true
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end

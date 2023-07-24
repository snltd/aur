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
        ok_names = %w[front.jpg front.png].freeze

        files.select { |f| ok_names.include?(f.basename.to_s) }
      end

      def cover_art_looks_ok?(file)
        x, y = FastImage.size(file)

        raise Aur::Exception::ArtfixNilSize if x.nil? || y.nil?

        raise Aur::Exception::LintDirCoverArtNotSquare if x != y

        raise Aur::Exception::LintDirCoverArtTooBig if x > ARTWORK_DEF

        return unless x < ARTWORK_MIN

        raise Aur::Exception::LintDirCoverArtTooSmall, "#{x} x #{y}"
      end
    end
  end
end

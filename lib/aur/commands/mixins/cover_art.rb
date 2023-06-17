# frozen_string_literal: true

require 'fastimage'

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
    end
  end
end

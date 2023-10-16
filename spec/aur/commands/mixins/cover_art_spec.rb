#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../../spec_helper'
require_relative '../../../../lib/aur/exception'
require_relative '../../../../lib/aur/commands/mixins/cover_art'

# Test for cover art mixin
#
class TestCoverArtMixin < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'mixins', 'cover_art')

  include Aur::Mixin::CoverArt

  def test_cover_art_looks_ok?
    assert cover_art_looks_ok?(
      T_DIR.join('tester.artwork_just_right', 'front.jpg')
    )

    assert_raises(Aur::Exception::LintDirCoverArtTooBig) do
      assert cover_art_looks_ok?(
        T_DIR.join('tester.artwork_too_big', 'front.jpg')
      )
    end

    assert_raises(Aur::Exception::LintDirCoverArtTooSmall) do
      assert cover_art_looks_ok?(
        T_DIR.join('tester.artwork_too_small', 'front.jpg')
      )
    end

    assert_raises(Aur::Exception::LintDirCoverArtNotSquare) do
      assert cover_art_looks_ok?(
        T_DIR.join('tester.artwork_not_square', 'front.jpg')
      )
    end
  end

  def test_arty
    assert_nil(arty([Pathname.new('/a/a.flac'), Pathname.new('/a/b.flac')]))

    assert_equal(
      Pathname.new('/a/front.jpg'),
      arty([Pathname.new('/a/a.flac'), Pathname.new('/a/front.jpg')])
    )
  end
end

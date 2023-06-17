#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../../spec_helper'
require_relative '../../../../lib/aur/exception'
require_relative '../../../../lib/aur/commands/mixins/cover_art'

# Test for cover art mixin
#
class TestCoverArtMixin < MiniTest::Test
  include Aur::Mixin::CoverArt

  ART_DIR = RES_DIR.join('lintdir-artwork')

  def test_square_enough?
    assert square_enough?(300, 300)
    assert square_enough?(300, 301)
    assert square_enough?(300, 299)
    refute square_enough?(300, 310)
  end

  def test_cover_art_looks_ok?
    assert cover_art_looks_ok?([ART_DIR.join('just_right', 'front.jpg')])

    assert_raises(Aur::Exception::LintDirCoverArtTooBig) do
      assert cover_art_looks_ok?([ART_DIR.join('too_big', 'front.jpg')])
    end

    assert_raises(Aur::Exception::LintDirCoverArtTooSmall) do
      assert cover_art_looks_ok?([ART_DIR.join('too_small', 'front.png')])
    end

    assert_raises(Aur::Exception::LintDirCoverArtNotSquare) do
      assert cover_art_looks_ok?([ART_DIR.join('not_square', 'front.jpg')])
    end
  end

  def test_arty
    assert_empty(arty([Pathname.new('/a/a.flac'), Pathname.new('/a/b.flac')]))
    assert_equal(
      [Pathname.new('/a/front.png')],
      arty([Pathname.new('/a/a.flac'), Pathname.new('/a/front.png')])
    )
    assert_equal(
      [Pathname.new('/a/front.jpg')],
      arty([Pathname.new('/a/a.flac'), Pathname.new('/a/front.jpg')])
    )
  end
end

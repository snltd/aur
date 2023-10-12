#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/artfix'

# Unit tests for Artfix class
#
class TestArtfix < Minitest::Test
  parallelize_me!

  def setup
    @t = Aur::Command::Artfix.new
  end

  def test_image_files
    afdir = RES_DIR.join('artfix')

    assert_equal(
      [afdir.join('albums', 'jesus_lizard.liar/cover.jpg')],
      @t.image_files(afdir.join('albums', 'jesus_lizard.liar'))
    )

    assert_equal(
      [afdir.join('albums', 'windy_and_carl.portal/Front.JPG')],
      @t.image_files(afdir.join('albums', 'windy_and_carl.portal'))
    )

    assert_equal(
      [],
      @t.image_files(RES_DIR.join('lintdir', 'flac', 'fall.eds_babe'))
    )
  end

  def test_new_name
    %w[something.jpg something.jpeg something.Jpg something.JPG].each do |f|
      assert_equal(RES_DIR.join('front.jpg'), @t.new_name(RES_DIR.join(f)))
    end

    assert_raises(Aur::Exception::UnsupportedFiletype) do
      @t.new_name(RES_DIR.join('something.png'))
    end
  end
end

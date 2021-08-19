#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/artfix'

# Unit tests for Artfix class
#
class TestArtfix < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::Command::Artfix.new
  end

  def test_candidates
    assert_equal(
      [RES_DIR + 'artfix' + 'albums/jesus_lizard.liar/cover.jpg',
       RES_DIR + 'artfix' + 'albums/windy_and_carl.portal/Front.JPG',
       RES_DIR + 'artfix' + 'eps/water_world.dead/front cover.Png'],
      t.candidates(RES_DIR + 'artfix').sort
    )

    assert_equal([], t.candidates(RES_DIR + 'lintdir' + 'flac'))
  end

  def test_new_name
    %w[something.jpg something.jpeg something.Jpg something.JPG].each do |f|
      assert_equal(TMP_DIR + 'front.jpg', t.new_name(TMP_DIR + f))
    end

    %w[something.png something.PNG].each do |f|
      assert_equal(TMP_DIR + 'front.png', t.new_name(TMP_DIR + f))
    end

    assert_raises(Aur::Exception::UnsupportedFiletype) do
      t.new_name(TMP_DIR + 'something.tiff')
    end
  end
end

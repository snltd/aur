#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/artfix'

# Unit tests for Artfix class
#
class TestArtfix < Minitest::Test
  attr_reader :t

  def setup
    @t = Aur::Command::Artfix.new
  end

  def test_candidates
    afdir = RES_DIR.join('artfix')

    assert_equal(
      [
        afdir.join('albums', 'jesus_lizard.liar/cover.jpg'),
        afdir.join('albums', 'windy_and_carl.portal/Front.JPG'),
        afdir.join('eps', 'water_world.dead/front cover.Png')
      ],
      t.candidates(afdir).sort
    )

    assert_equal([],
                 t.candidates(RES_DIR.join('lintdir', 'flac')))
  end

  def test_new_name
    %w[something.jpg something.jpeg something.Jpg something.JPG].each do |f|
      assert_equal(TMP_DIR.join('front.jpg'), t.new_name(TMP_DIR + f))
    end

    %w[something.png something.PNG].each do |f|
      assert_equal(TMP_DIR.join('front.png'), t.new_name(TMP_DIR + f))
    end

    assert_raises(Aur::Exception::UnsupportedFiletype) do
      t.new_name(TMP_DIR.join('something.tiff'))
    end
  end
end

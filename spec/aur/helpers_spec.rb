#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/helpers'

# Tests
#
class Test < MiniTest::Test
  include Aur::Helpers

  FLAC_DIR = RES_DIR.join('lintdir', 'flac')
  MP3_DIR = RES_DIR.join('lintdir', 'mp3')

  def test_escaped
    assert_equal('"Spiderland"', escaped('Spiderland'))
    assert_equal('"Theme from \"Shaft\""', escaped('Theme from "Shaft"'))
    assert_equal('"\"Loads\" of \"Quotes\""', escaped('"Loads" of "Quotes"'))
  end

  def test_recursive_dir_list
    assert_equal(
      lintdirs,
      Aur::Helpers.recursive_dir_list([RES_DIR.join('lintdir')])
    )

    assert_equal(
      lintdirs,
      Aur::Helpers.recursive_dir_list(
        [RES_DIR.join('lintdir'), FLAC_DIR, MP3_DIR]
      )
    )
  end

  def lintdirs
    [RES_DIR.join('lintdir'),
     FLAC_DIR,
     FLAC_DIR.join('slint.spiderland_remastered'),
     FLAC_DIR.join('slint.spiderland_remastered/bonus_disc'),
     FLAC_DIR.join('fall.eds_babe'),
     MP3_DIR,
     MP3_DIR.join('heavenly.atta_girl'),
     MP3_DIR.join('broadcast.pendulum'),
     MP3_DIR.join('pet_shop_boys.very'),
     MP3_DIR.join('pet_shop_boys.very/further_listening_1992-1994'),
     MP3_DIR.join('tegan_and_sara.the_con'),
     MP3_DIR.join('seefeel.starethrough_ep'),
     MP3_DIR.join('afx.analogue_bubblebath'),
     MP3_DIR.join('polvo.cor.crane_secret'),
     MP3_DIR.join('pram.meshes')].sort
  end
end

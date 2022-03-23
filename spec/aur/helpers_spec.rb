#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/helpers'

# Tests
#
class Test < MiniTest::Test
  include Aur::Helpers

  FLAC_DIR = RES_DIR + 'lintdir' + 'flac'
  MP3_DIR = RES_DIR + 'lintdir' + 'mp3'

  def test_escaped
    assert_equal('"Spiderland"', escaped('Spiderland'))
    assert_equal('"Theme from \"Shaft\""', escaped('Theme from "Shaft"'))
    assert_equal('"\"Loads\" of \"Quotes\""', escaped('"Loads" of "Quotes"'))
  end

  def test_recursive_dir_list
    assert_equal(lintdirs,
                 Aur::Helpers.recursive_dir_list([RES_DIR + 'lintdir']))

    assert_equal(lintdirs,
                 Aur::Helpers.recursive_dir_list(
                   [RES_DIR + 'lintdir', FLAC_DIR, MP3_DIR]
                 ))
  end

  def lintdirs
    [RES_DIR + 'lintdir',
     FLAC_DIR,
     FLAC_DIR + 'slint.spiderland_remastered',
     FLAC_DIR + 'slint.spiderland_remastered/bonus_disc',
     FLAC_DIR + 'fall.eds_babe',
     MP3_DIR,
     MP3_DIR + 'heavenly.atta_girl',
     MP3_DIR + 'broadcast.pendulum',
     MP3_DIR + 'pet_shop_boys.very',
     MP3_DIR + 'pet_shop_boys.very/further_listening_1992-1994',
     MP3_DIR + 'tegan_and_sara.the_con',
     MP3_DIR + 'seefeel.starethrough_ep',
     MP3_DIR + 'afx.analogue_bubblebath',
     MP3_DIR + 'polvo.cor.crane_secret',
     MP3_DIR + 'pram.meshes'].sort
  end
end

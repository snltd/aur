#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/action'

# test the command controller
#
class CommandTest < MiniTest::Test
  attr_reader :obj

  FLAC_DIR = RES_DIR + 'lintdir' + 'flac'
  MP3_DIR = RES_DIR + 'lintdir' + 'mp3'

  def setup
    @obj = Aur::Action.new(:info, RES_DIR.children)
  end

  def test_action
    assert_equal(:Info, obj.action)
  end

  def test_flist
    suffixes = %w[.flac .mp3]

    assert(obj.flist.all? { |f| f.instance_of?(Pathname) })
    assert(obj.flist.all? { |f| suffixes.include?(f.extname) })
  end

  def test_recursive_dir_list
    assert_equal(lintdirs, obj.recursive_dir_list([RES_DIR + 'lintdir']))

    assert_equal(lintdirs, obj.recursive_dir_list(
                             [RES_DIR + 'lintdir', FLAC_DIR, MP3_DIR]
                           ))
  end

  def lintdirs
    [RES_DIR + 'lintdir',
     FLAC_DIR,
     FLAC_DIR + 'slint.spiderland_remastered',
     FLAC_DIR + 'slint.spiderland_remastered/slint.spiderland_bonus_disc',
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

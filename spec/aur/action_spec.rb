#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/action'

# test the command controller
#
class CommandTest < MiniTest::Test
  attr_reader :obj

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
                             [RES_DIR + 'lintdir', FDIR, MDIR]
                           ))
  end

  def lintdirs
    [RES_DIR + 'lintdir',
     FDIR,
     FDIR + 'slint.spiderland_remastered',
     FDIR + 'slint.spiderland_remastered/slint.spiderland_bonus_disc',
     FDIR + 'fall.eds_babe',
     MDIR,
     MDIR + 'heavenly.atta_girl',
     MDIR + 'broadcast.pendulum',
     MDIR + 'pet_shop_boys.very',
     MDIR + 'pet_shop_boys.very/further_listening_1992-1994',
     MDIR + 'tegan_and_sara.the_con',
     MDIR + 'seefeel.starethrough_ep',
     MDIR + 'afx.analogue_bubblebath',
     MDIR + 'polvo.cor.crane_secret',
     MDIR + 'pram.meshes'].sort
  end
end

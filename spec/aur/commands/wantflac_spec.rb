#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/wantflac'

# Test for wantflac methods
#
class TestLint < MiniTest::Test
  def setup
    @t = Aur::Command::Wantflac.new(Pathname.new(RES_DIR))
  end

  def test_album_name
    assert_equal(
      'pale_saints.half-life_ep',
      @t.album_name(Pathname.new('/storage/mp3/eps/pale_saints.half-life_ep'))
    )

    assert_equal(
      'sonic_youth.dirty',
      @t.album_name(
        Pathname.new('/storage/albums/pqrs/sonic_youth.dirty/disc_1')
      )
    )

    assert_equal(
      'slint.spiderland',
      @t.album_name(
        Pathname.new('/storage/albums/pqrs/slint.spiderland/bonus_disc')
      )
    )
  end

  def test_filter
    dirs = [
      [Pathname.new('albums/abc/broadcast.tender_buttons'), 4],
      [Pathname.new('eps/slint.untitled'), 4],
      [Pathname.new('radio_shows/armando_iannucci.down_your_ear'), 1],
      [Pathname.new('spoken_word/derek_and_clive.live'), 6],
      [Pathname.new('christmas/spackers/various.christmas_spacker_2008'), 20]
    ]

    assert_equal(
      [[Pathname.new('albums/abc/broadcast.tender_buttons'), 4],
      [Pathname.new('eps/slint.untitled'), 4]],
      @t.filter(dirs)
    )
  end
end

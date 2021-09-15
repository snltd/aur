#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/wantflac'

# Test for wantflac methods
#
class TestLint < MiniTest::Test
  def test_album_name
    t = Aur::Command::Wantflac.new(Pathname.new(RES_DIR))

    assert_equal(
      'pale_saints.half-life_ep',
      t.album_name(Pathname.new('/storage/mp3/eps/pale_saints.half-life_ep'))
    )

    assert_equal(
      'sonic_youth.dirty',
      t.album_name(
        Pathname.new('/storage/albums/pqrs/sonic_youth.dirty/disc_1')
      )
    )

    assert_equal(
      'slint.spiderland',
      t.album_name(
        Pathname.new('/storage/albums/pqrs/slint.spiderland/bonus_disc')
      )
    )
  end
end

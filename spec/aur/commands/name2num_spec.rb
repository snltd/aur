#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/name2num'

# Test for name2num command. Lots of Spies, so don't parallelize
#
class TestName2num < Minitest::Test
  def test_flac
    t = Aur::Command::Name2num.new(
      RES_DIR.join('01.test_artist.untagged_song.flac')
    )

    del = Spy.on(t.info.raw, :comment_del)
    add = Spy.on(t.info.raw, :comment_add)
    upd = Spy.on(t.info.raw, :update!)

    assert_output(/^\s+t_num -> 1\n/, '') { t.run }
    assert_empty del.calls
    assert_equal(['TRACKNUMBER=1'], add.calls.map(&:args).flatten)
    assert upd.has_been_called?
  end

  def test_flac_no_number
    t = Aur::Command::Name2num.new(RES_DIR.join('bad_name.flac'))
    del = Spy.on(t.info.raw, :comment_del)
    add = Spy.on(t.info.raw, :comment_add)
    upd = Spy.on(t.info.raw, :update!)

    assert_output('', "No number found at start of filename\n") { t.run }
    assert_empty(del.calls.map(&:args).flatten)
    assert_empty(add.calls.map(&:args).flatten)
    refute upd.has_been_called?
  end

  def test_mp3
    t = Aur::Command::Name2num.new(
      RES_DIR.join('01.test_artist.untagged_song.mp3')
    )

    spy = Spy.on(Mp3Info, :open)
    t.run
    assert_equal(1, spy.calls.count)
    assert_equal([RES_DIR.join('01.test_artist.untagged_song.mp3')],
                 spy.calls.first.args)
  end

  def test_mp3_no_number
    t = Aur::Command::Name2num.new(RES_DIR.join('bad_name.mp3'))
    spy = Spy.on(Mp3Info, :open)
    assert_output('', "No number found at start of filename\n") { t.run }
    refute spy.has_been_called?
  end
end

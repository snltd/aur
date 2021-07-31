#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/number'

# Test for number command
#
class TestNumber < MiniTest::Test
  def test_flac
    totest = Aur::Number::Generic.new(RES_DIR + '01.the_null_set.song_one.flac')
    del = Spy.on(totest.info.raw, :comment_del)
    add = Spy.on(totest.info.raw, :comment_add)
    upd = Spy.on(totest.info.raw, :update!)

    out, err = capture_io { totest.run }
    assert_empty(err)
    assert_equal('t_num -> 1', out.strip)
    assert_equal(%w[TRACKNUMBER], del.calls.map(&:args).flatten)
    assert_equal(['TRACKNUMBER=1'], add.calls.map(&:args).flatten)
    assert upd.has_been_called?
  end

  def test_flac_no_number
    totest = Aur::Number::Generic.new(RES_DIR + 'bad_name.flac')
    del = Spy.on(totest.info.raw, :comment_del)
    add = Spy.on(totest.info.raw, :comment_add)
    upd = Spy.on(totest.info.raw, :update!)

    out, err = capture_io { totest.run }
    assert_empty(out)
    assert_equal("No number found at start of filename\n", err)

    assert_empty(del.calls.map(&:args).flatten)
    assert_empty(add.calls.map(&:args).flatten)
    refute upd.has_been_called?
  end

  def test_mp3
    totest = Aur::Number::Generic.new(RES_DIR + '01.the_null_set.song_one.mp3')
    spy = Spy.on(Mp3Info, :open)
    out, err = capture_io { totest.run }
    assert_empty(err)
    assert_equal('t_num -> 1', out.strip)
    assert spy.has_been_called?
  end

  def test_mp3_no_number
    totest = Aur::Number::Generic.new(RES_DIR + 'bad_name.mp3')
    spy = Spy.on(Mp3Info, :open)
    out, err = capture_io { totest.run }
    assert_empty(out)
    assert_equal("No number found at start of filename\n", err)
    refute spy.has_been_called?
  end
end

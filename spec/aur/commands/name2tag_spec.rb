#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/name2tag'

# Test for name2tag command
#
class TestName2tag < MiniTest::Test
  attr_reader :flac, :mp3

  def setup
    @flac = Aur::Name2tag::Generic.new(FLAC_TEST)
    @mp3 = Aur::Name2tag::Generic.new(MP3_TEST)
  end

  def test_flac
    del = Spy.on(flac.info.raw, :comment_del)
    add = Spy.on(flac.info.raw, :comment_add)
    upd = Spy.on(flac.info.raw, :update!)
    out, err = capture_io { flac.run }
    assert_empty(err)
    out = out.split("\n")
    assert_equal(FLAC_TEST.to_s, out.first)
    assert_equal('artist -> Unknown Artist', out[1].strip)
    assert_equal('title -> Test Tone (100hz)', out[2].strip)
    assert_equal('album -> Resources', out[3].strip)
    assert_equal('tracknumber -> 00', out.last.strip)
    assert_equal(%w[ARTIST TITLE ALBUM TRACKNUMBER],
                 del.calls.map(&:args).flatten)
    assert_equal(['ARTIST=Unknown Artist',
                  'TITLE=Test Tone (100hz)',
                  'ALBUM=Resources',
                  'TRACKNUMBER=00'],
                 add.calls.map(&:args).flatten)
    assert upd.has_been_called?
  end

  def test_mp3
    spy = Spy.on(Mp3Info, :open)
    out, err = capture_io { mp3.run }
    assert_empty(err)
    out = out.split("\n")
    assert_equal(MP3_TEST.to_s, out.first)
    assert_equal('artist -> Unknown Artist', out[1].strip)
    assert_equal('title -> Test Tone (100hz)', out[2].strip)
    assert_equal('album -> Resources', out[3].strip)
    assert_equal('tracknum -> 00', out.last.strip)
    assert spy.has_been_called?
  end
end

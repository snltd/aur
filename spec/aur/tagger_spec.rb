#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tagger'
require_relative '../../lib/aur/fileinfo'

class TestTagger < MiniTest::Test
  def test_flac
    flacinfo = Aur::FileInfo::Flac.new(FLAC_TEST)
    t = Aur::Tagger::Flac.new(flacinfo, {})

    del = Spy.on(t.info.raw, :comment_del)
    add = Spy.on(t.info.raw, :comment_add)
    upd = Spy.on(t.info.raw, :update!)

    out, err = capture_io { t.tag!(test_tags) }

    assert_empty(err)
    assert_equal(expected_output, out)

    assert_equal(%w[ARTIST TITLE ALBUM TRACKNUMBER],
                 del.calls.map(&:args).flatten)

    assert_equal(['ARTIST=The Singer',
                  'TITLE=A Song',
                  'ALBUM=Their Record',
                  'TRACKNUMBER=3'],
                 add.calls.map(&:args).flatten)

    assert upd.has_been_called?
  end

  def test_mp3
    mp3info = Aur::FileInfo::Mp3.new(MP3_TEST)
    t = Aur::Tagger::Mp3.new(mp3info, {})

    spy = Spy.on(Mp3Info, :open)

    out, err = capture_io { t.tag!(test_tags) }

    assert_empty(err)
    assert_equal(expected_output, out)

    assert spy.has_been_called?
  end

  def test_prep
    mp3info = Aur::FileInfo::Mp3.new(MP3_TEST)
    t = Aur::Tagger::Mp3.new(mp3info, {})

    assert_equal(
      { artist: 'Slint', title: 'Washer', t_num: 4, year: 1991 },
      t.prep({ artist: 'Slint', title: 'Washer', t_num: '04', year: '1991' })
    )
  end

  def test_tags
    { artist: 'The Singer',
      title: 'A Song',
      album: 'Their Record',
      t_num: 3 }
  end

  def expected_output
    "      artist -> The Singer\n" \
      "       title -> A Song\n" \
      "       album -> Their Record\n" \
      "       t_num -> 3\n"
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/name2tag'

# Test for name2tag command
#
class TestName2tag < MiniTest::Test
  def test_flac
    t1 = Aur::Command::Name2tag.new(FLAC_TEST)

    assert_equal(
      { artist: 'Unknown Artist',
        title: 'Test Tone (100hz)',
        album: 'Resources',
        t_num: '00' },
      t1.tags_from_filename
    )

    t2 = Aur::Command::Name2tag.new(RES_DIR + '01.the_null_set.song_one.flac')

    assert_equal(
      { artist: 'The Null Set',
        title: 'Song One',
        album: 'Resources',
        t_num: '01' },
      t2.tags_from_filename
    )
  end

  def test_mp3
    t1 = Aur::Command::Name2tag.new(MP3_TEST)

    assert_equal(
      { artist: 'Unknown Artist',
        title: 'Test Tone (100hz)',
        album: 'Resources',
        t_num: '00' }, t1.tags_from_filename
    )

    t2 = Aur::Command::Name2tag.new(RES_DIR + '01.the_null_set.song_one.mp3')

    assert_equal(
      { artist: 'The Null Set',
        title: 'Song One',
        album: 'Resources',
        t_num: '01' },
      t2.tags_from_filename
    )
  end
end

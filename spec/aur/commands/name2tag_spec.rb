#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/name2tag'

# Test for name2tag command
#
class TestName2tag < MiniTest::Test
  N2T_DIR = RES_DIR + 'name2tag' + 'null_set.some_stuff_by'

  def test_flac_and_mp3
    SUPPORTED_TYPES.each do |_type|
      t1 = Aur::Command::Name2tag.new(RES_DIR + 'test_tone-100hz.flac')

      assert_equal(
        { artist: 'Unknown Artist',
          title: 'Test Tone (100hz)',
          album: 'Resources',
          t_num: '00' },
        t1.tags_from_filename
      )

      t2 = Aur::Command::Name2tag.new(N2T_DIR + '01.the_null_set.song_one.mp3')

      assert_equal(
        { artist: 'The Null Set',
          title: 'Song One',
          album: 'Some Stuff By',
          t_num: '01' },
        t2.tags_from_filename
      )
    end
  end
end

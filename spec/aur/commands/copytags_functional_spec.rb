#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur copytags' commands against things, and verify the results
#
class TestCopytagsCommand < Minitest::Test
  parallelize_me!

  def test_remove_v1_tags_from_file_with_both
    with_test_file('copytags') do |dir|
      flac = dir.join('flac', '01.artist.song.flac')
      mp3 = dir.join('mp3', '01.artist.song.mp3')

      flacinfo = Aur::FileInfo.new(flac)
      mp3info = Aur::FileInfo.new(mp3)

      assert_equal({ artist: nil,
                     album: nil,
                     title: nil,
                     t_num: nil,
                     year: nil,
                     genre: 'Noise' },
                   mp3info.our_tags)

      assert_equal(flac_tags, flacinfo.our_tags)

      capture_io { Aur::Action.new(:copytags, [mp3]).run! }

      assert_equal(flac_tags, Aur::FileInfo.new(mp3).our_tags)
    end
  end

  def flac_tags
    { artist: 'Artist',
      album: 'Test Album',
      title: 'Song',
      t_num: '1',
      year: '2021',
      genre: 'Noise' }
  end
end

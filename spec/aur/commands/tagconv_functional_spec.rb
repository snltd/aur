#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur tagconv' commands against things, and verify the results
#
class TestTagconvCommand < MiniTest::Test
  # include Aur::CommandTests

  def test_remove_v1_tags_from_file_with_both
    with_test_file('test_tone--100hz.mp3') do |f|
      info = Aur::FileInfo.new(f)

      v1_tags = { 'title' => '100hz',
                  'artist' => 'Test Tone',
                  'album' => 'Test Tone',
                  'year' => 2021,
                  'comments' => 'Test file',
                  'genre' => 39,
                  'genre_s' => 'Noise' }

      v2_tags = { artist: 'Test Tones',
                  album: 'Test Tones',
                  title: '100hz',
                  t_num: '6',
                  year: '2021',
                  genre: 'Noise' }

      assert_equal(v1_tags, info.raw.tag1)
      assert_equal(v2_tags, info.our_tags)

      assert_output("       Removing 7 ID3v1 tags\n", '') do
        Aur::Action.new(:tagconv, [f]).run!
      end

      info = Aur::FileInfo.new(f)

      assert_empty(info.raw.tag1)
      assert_equal(v2_tags, info.our_tags)
    end
  end

  def test_promote_tags
    with_test_file('01.test_artist.v1_tags_only.mp3') do |f|
      info = Aur::FileInfo.new(f)

      assert_equal(
        { 'title' => 'Song Title',
          'artist' => 'Test Artist',
          'album' => 'Test Album',
          'year' => 2021,
          'tracknum' => 1,
          'genre' => 20,
          'genre_s' => 'Alternative' },
        info.raw.tag1
      )

      assert_equal(
        { artist: nil,
          album: nil,
          title: nil,
          t_num: nil,
          year: nil,
          genre: 'Noise' },
        info.our_tags
      )

      assert_output("       title -> Song Title\n" \
                    "      artist -> Test Artist\n" \
                    "       album -> Test Album\n" \
                    "        year -> 2021\n" \
                    "       genre -> Alternative\n" \
                    "       Removing 7 ID3v1 tags\n",
                    '') do
        Aur::Action.new(:tagconv, [f]).run!
      end

      info = Aur::FileInfo.new(f)

      assert_empty(info.raw.tag1)

      assert_equal({ artist: 'Test Artist',
                     album: 'Test Album',
                     title: 'Song Title',
                     t_num: nil,
                     year: '2021',
                     genre: 'Alternative' },
                   info.our_tags)
    end
  end

  def action
    :tagconv
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/flac2mp3'
require_relative '../../../lib/aur/constants'

# Tests for flac2mp3 command
#
class TestFlac2Mp3 < Minitest::Test
  parallelize_me!

  def setup
    @t = Aur::Command::Flac2mp3.new(UNIT_FLAC)
  end

  def test_construct_command
    assert_equal(
      "#{BIN[:flac]} -dsc \"#{UNIT_FLAC}\" | #{BIN[:lame]} " \
      '-q2 --vbr-new --preset 128 --id3v2-only --add-id3v2 --silent ' \
      '--tt "Song Title" --ta "Band" --tl "Album Title" --ty "1993" ' \
      "--tn \"4\" --tg \"Noise\" - \"#{UNIT_MP3}\"",
      @t.construct_command(UNIT_FLAC, UNIT_MP3, test_tags)
    )
  end

  def test_lame_tag_opts
    assert_equal(
      '--tt "Song Title" --ta "Band" --tl "Album Title" --ty "1993"',
      @t.lame_tag_opts(title: 'Song Title',
                       artist: 'Band',
                       album: 'Album Title',
                       genre: nil,
                       year: 1993)
    )

    assert_equal(
      '--tt "Title with \"Quotes\"" --ta "Band"',
      @t.lame_tag_opts(title: 'Title with "Quotes"', artist: 'Band')
    )
  end

  private

  def test_tags
    { title: 'Song Title',
      artist: 'Band',
      album: 'Album Title',
      genre: 'Noise',
      t_num: '4',
      year: '1993' }
  end
end

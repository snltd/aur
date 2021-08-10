#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/flac2mp3'

# Tests for flac2mp3 command
#
class TestFlac2Mp3 < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::Command::Flac2mp3.new(FLAC_TEST)
  end

  def test_construct_command
    assert_equal(
      "/opt/local/bin/flac -dsc \"#{FLAC_TEST}\" | /opt/local/bin/lame " \
      '-h --vbr-new --preset 128 --id3v2-only --add-id3v2 --silent ' \
      '--tt "Song Title" --ta "Band" --tl "Album Title" --ty "1993" ' \
      "--tn \"4\" --tg \"Noise\" - \"#{MP3_TEST}\"",
      t.construct_command(FLAC_TEST, test_tags)
    )
  end

  def test_lame_tag_opts
    assert_equal(
      '--tt "Song Title" --ta "Band" --tl "Album Title" --ty "1993"',
      t.lame_tag_opts(title: 'Song Title',
                      artist: 'Band',
                      album: 'Album Title',
                      genre: nil,
                      year: 1993)
    )

    assert_equal(
      '--tt "Title with \"Quotes\"" --ta "Band"',
      t.lame_tag_opts(title: 'Title with "Quotes"', artist: 'Band')
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
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/flac2mp3'
require_relative '../../../lib/aur/constants'

# Tests for flac2mp3 command
#
class TestFlac2Mp3 < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'flac2mp3')

  def setup
    @t = Aur::Command::Flac2mp3.new(T_DIR.join('test.flac'))
  end

  def test_construct_command
    assert_equal(
      "#{BIN[:flac]} -dsc \"#{T_DIR.join('test.flac')}\" " \
      "| #{BIN[:lame]} " \
      '-q2 --vbr-new --preset 128 --id3v2-only --add-id3v2 --silent ' \
      '--tt "Song Title" --ta "Band" --tl "Album Title" --ty "1993" ' \
      "--tn \"4\" --tg \"Noise\" - \"#{T_DIR.join('test.mp3')}\"",
      @t.construct_command(
        T_DIR.join('test.flac'),
        T_DIR.join('test.mp3'),
        test_tags
      )
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

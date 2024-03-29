#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/tag2name'

# Tests for tag2name command
#
class TestTag2name < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'tag2name')

  def setup
    @flac = Aur::Command::Tag2name.new(UNIT_FLAC)
    @mp3 = Aur::Command::Tag2name.new(UNIT_MP3)
  end

  def test_safe_filename_flac
    assert_equal('06.test_tones.100hz.flac', @flac.safe_filename)
  end

  def test_safe_filename_mp3
    assert_equal('06.test_tones.100hz.mp3', @mp3.safe_filename)
  end

  def test_safe_filename_flac_lots_of_missing_data
    assert_equal('00.unknown_artist.a_song.flac',
                 @flac.safe_filename(TestTags.new(title: 'A Song')))
  end

  def test_safe_filename_flac_missing_data
    assert_equal('07.unknown_artist.another_song.flac',
                 @flac.safe_filename(TestTags.new(t_num: 7,
                                                  title: 'Another Song')))
  end

  def test_safe_filename_mp3_all_data
    assert_equal('10.band.song.mp3',
                 @mp3.safe_filename(
                   TestTags.new(t_num: 10, artist: 'Band', title: 'Song')
                 ))
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/tag2name'

# Tests for tag2name command
#
class TestTag2name < MiniTest::Test
  attr_reader :flac, :mp3

  def setup
    @flac = Aur::Command::Tag2name.new(RES_DIR + 'test_tone-100hz.flac')
    @mp3 = Aur::Command::Tag2name.new(RES_DIR + 'test_tone-100hz.mp3')
  end

  def test_run
    mv = Spy.on(FileUtils, :mv)
    assert_output("test_tone-100hz.flac -> 06.test_tones.100hz.flac\n", '') do
      flac.run
    end

    assert(mv.has_been_called?)
    assert_equal([RES_DIR + 'test_tone-100hz.flac',
                  RES_DIR + '06.test_tones.100hz.flac'],
                 mv.calls.first.args)
  end

  def test_safe_filename_flac
    assert_equal('06.test_tones.100hz.flac', flac.safe_filename)
  end

  def test_safe_filename_mp3
    assert_equal('06.test_tones.100hz.mp3', mp3.safe_filename)
  end

  def test_safe_filename_flac_lots_of_missing_data
    assert_equal('00.unknown_artist.a_song.flac',
                 flac.safe_filename(TestTags.new(title: 'A Song')))
  end

  def test_safe_filename_flac_missing_data
    assert_equal('07.unknown_artist.another_song.flac',
                 flac.safe_filename(TestTags.new(t_num: 7,
                                                 title: 'Another Song')))
  end

  def test_safe_filename_mp3_all_data
    assert_equal('10.band.song.mp3',
                 mp3.safe_filename(
                   TestTags.new(t_num: 10, artist: 'Band', title: 'Song')
                 ))
  end
end

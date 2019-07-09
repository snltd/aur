#!/usr/bin/env ruby
# frozen_string_literal: true

require 'ostruct'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/numname'

# Tests for numname command
#
class TestNumName < MiniTest::Test
  attr_reader :flac, :mp3

  def setup
    @flac = Aur::NumName::Generic.new(FLAC_TEST)
    @mp3 = Aur::NumName::Generic.new(MP3_TEST)
  end

  def test_run
    mv = Spy.on(FileUtils, :mv)
    out, err = capture_io { flac.run }

    assert_empty(err)
    assert_equal("test_tone-100hz.flac -> 06.test_tone-100hz.flac\n", out)

    assert(mv.has_been_called?)
    assert_equal([FLAC_TEST, RES_DIR + '06.test_tone-100hz.flac'],
                 mv.calls.first.args)
  end

  def test_new_filename_flac
    assert_equal('06.test_tone-100hz.flac', flac.new_filename)
  end

  def test_new_filename_mp3
    assert_equal('06.test_tone-100hz.mp3', mp3.new_filename)
  end

  def test_new_filename_flac_missing_data
    assert_equal('00.test_tone-100hz.flac',
                 flac.new_filename(OpenStruct.new(title: 'Another Song')))
  end

  def test_new_filename_mp3_all_data
    assert_equal('10.test_tone-100hz.mp3',
                 mp3.new_filename(
                   OpenStruct.new(t_num: 10, artist: 'Band', title: 'Song')
                 ))
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/info'

# Test info command
#
class TestInfo < Minitest::Test
  parallelize_me!

  def setup
    @flac = Aur::Command::Info.new(UNIT_FLAC)
  end

  def test_fmt_line
    assert_equal('   Artist : Test Tones',
                 @flac.fmt_line(:Artist, 'Test Tones'))
  end

  def test_type
    assert_equal('FLAC', @flac.fields[:Type])
  end

  def test_filename
    assert_equal('test.flac', @flac.fields[:Filename])
  end

  def test_bitrate
    assert_equal('16-bit/44100Hz', @flac.fields[:Bitrate])
  end

  def test_track_number
    assert_equal('6', @flac.fields[:'Track no'])
  end

  def test_track_artist
    assert_equal('Test Tones', @flac.fields[:Artist])
  end

  def test_f_artist
    assert_equal('unknown_artist', @flac.info.f_artist)
  end

  def test_f_title
    assert_equal('test', @flac.info.f_title)
  end

  def test_f_album
    assert_equal('unit', @flac.info.f_album)
  end

  def test_f_t_num
    assert_equal('00', @flac.info.f_t_num)
  end
end

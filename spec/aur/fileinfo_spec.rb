#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/fileinfo'

# Test FileInfo class
#
class TestFileInfo < MiniTest::Test
  attr_reader :flac, :mp3

  def setup
    @flac = Aur::FileInfo.new(FLAC_TEST)
    @mp3 = Aur::FileInfo.new(MP3_TEST)
  end

  def test_flac_bitrate
    assert_equal('16-bit/44100Hz', flac.bitrate)
  end

  def test_flac_artist
    assert_equal('Test Tones', flac.artist)
  end

  def test_flac_album
    assert_equal('Test Tones', flac.album)
  end

  def test_flac_title
    assert_equal('100hz', flac.title)
  end

  def test_flac_track_no
    assert_equal(6, flac.t_num.to_i)
  end

  def test_flac_genre
    assert_nil(flac.genre)
  end

  def test_flac_year
    assert_nil(flac.year)
  end

  def test_flac_missing
    assert_raises(NoMethodError) { flac.merp }
  end

  def test_mp3_bitrate
    assert_equal('64kbps', mp3.bitrate)
  end

  def test_mp3_artist
    assert_equal('Test Tones', mp3.artist)
  end

  def test_mp3_album
    assert_equal('Test Tones', mp3.album)
  end

  def test_mp3_title
    assert_equal('100hz', mp3.title)
  end

  def test_mp3_track_no
    assert_equal(6, mp3.t_num.to_i)
  end

  def test_mp3_genre
    assert_equal('Noise', mp3.genre)
  end

  def test_mp3_year
    assert_equal('2021', mp3.year)
  end

  def test_mp3_missing
    assert_raises(NoMethodError) { mp3.merp }
  end

  def test_prt_name
    assert_equal('test_tone-100hz.flac', Aur::FileInfo.new(FLAC_TEST).prt_name)
    assert_equal('test_tone...', Aur::FileInfo.new(FLAC_TEST).prt_name(12))
  end

  def test_picture?
    refute(flac.picture?)
    with_pic = Aur::FileInfo.new(RES_DIR + 'unstripped.flac')
    assert(with_pic.picture?)
  end

  def test_unsupported
    assert_raises(Aur::Exception::UnsupportedFiletype) do
      Aur::FileInfo.new(RES_DIR + 'front.png')
    end

    assert_raises(Aur::Exception::UnsupportedFiletype) do
      Aur::FileInfo.new(RES_DIR)
    end
  end

  def test_filetype
    assert_equal('flac', flac.filetype)
    assert_equal('mp3', mp3.filetype)
  end
end

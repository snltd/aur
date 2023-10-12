#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/fileinfo'

# Test FileInfo class
#
class TestFileInfo < Minitest::Test
  parallelize_me!

  def setup
    @flac = Aur::FileInfo.new(RES_DIR.join('test_tone--100hz.flac'))
    @mp3 = Aur::FileInfo.new(RES_DIR.join('test_tone--100hz.mp3'))
  end

  def test_time
    assert_equal('0.5', @flac.time)
    assert_equal('0.6', @mp3.time)
  end

  def test_bitrate
    assert_equal('16-bit/44100Hz', @flac.bitrate)
    assert_equal('64kbps', @mp3.bitrate)
  end

  def test_artist
    assert_equal('Test Tones', @flac.artist)
    assert_equal('Test Tones', @mp3.artist)
  end

  def test_album
    assert_equal('Test Tones', @flac.album)
    assert_equal('Test Tones', @mp3.album)
  end

  def test_title
    assert_equal('100hz', @flac.title)
    assert_equal('100hz', @mp3.title)
  end

  def test_track_no
    assert_equal(6, @flac.t_num.to_i)
    assert_equal(6, @mp3.t_num.to_i)
  end

  def test_genre
    assert_equal('Noise', @flac.genre)
    assert_equal('Noise', @mp3.genre)
  end

  def test_year
    assert_equal('2021', @flac.year)
    assert_equal('2021', @mp3.year)
  end

  def test_missing
    assert_raises(NoMethodError) { @flac.merp }
    assert_raises(NoMethodError) { @mp3.merp }
  end

  def test_partner
    fdir = RES_DIR.join('fileinfo', 'flac', 'singer.lp')
    mdir = RES_DIR.join('fileinfo', 'mp3', 'singer.lp')

    assert_equal(
      fdir.join('01.singer.song.flac'),
      @mp3.partner(mdir.join('01.singer.song.mp3'))
    )

    assert_equal(
      mdir.join('01.singer.song.mp3'),
      @flac.partner(fdir.join('01.singer.song.flac'))
    )
  end

  def test_prt_name
    assert_equal(
      'test_tone--100hz.flac',
      Aur::FileInfo.new(RES_DIR.join('test_tone--100hz.flac')).prt_name
    )
    assert_equal(
      'test_tone...',
      Aur::FileInfo.new(RES_DIR.join('test_tone--100hz.flac')).prt_name(12)
    )
  end

  def test_picture?
    refute(@flac.picture?)
    with_pic = Aur::FileInfo.new(RES_DIR.join('unstripped.flac'))
    assert(with_pic.picture?)
  end

  def test_unsupported
    assert_raises(Aur::Exception::UnsupportedFiletype) do
      Aur::FileInfo.new(RES_DIR.join('front.png'))
    end

    assert_raises(Aur::Exception::UnsupportedFiletype) do
      Aur::FileInfo.new(RES_DIR)
    end
  end

  def test_filetype
    assert_equal('flac', @flac.filetype)
    assert_equal('mp3', @mp3.filetype)
  end

  def test_raw_bitrate?
    assert_equal(44_100, @flac.raw_bitrate)
    assert_equal(64, @mp3.raw_bitrate)
  end

  def test_is_it_this_or_that
    assert @flac.flac?
    assert @mp3.mp3?
    refute @flac.mp3?
    refute @mp3.flac?
  end
end

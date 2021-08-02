#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/renamers'
require_relative '../../lib/aur/fileinfo'

class TestRenamers < MiniTest::Test
  include Aur::Renamers

  def test_track_fnum
    assert_equal('06', track_fnum(flac_info))
    assert_equal('00', track_fnum(mp3_info))
  end

  def test_artist_fname
    assert_equal('test_tones', artist_fname(flac_info))
    assert_equal('unknown_artist', artist_fname(mp3_info))
  end

  def test_album_fname
    assert_equal('test_tones', album_fname(flac_info))
    assert_equal('unknown_album', album_fname(mp3_info))
  end

  def test_track_fname
    assert_equal('100hz', track_fname(flac_info))
    assert_equal('no_title', track_fname(mp3_info))
  end

  def test_file_suffix
    assert_equal('flac', file_suffix(flac_info))
    assert_equal('mp3', file_suffix(mp3_info))
  end

  def test_renumbered_file
    assert_equal(Pathname.new('/a/03.somefile.flac'),
                 renumbered_file(3, Pathname.new('/a/somefile.flac')))
    assert_equal(Pathname.new('/a/04.somefile.flac'),
                 renumbered_file(4, Pathname.new('/a/02.somefile.flac')))
    assert_equal(Pathname.new('/a/04.band.song.mp3'),
                 renumbered_file(4, Pathname.new('/a/13.band.song.mp3')))
    assert_equal(RES_DIR + '19.test_tone-100hz.flac',
                 renumbered_file(19, FLAC_TEST))
  end

  def test_rename_file_ok
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      out, err = capture_io do
        rename_file(f, TMP_DIR + 'target_file.mp3')
      end

      assert_equal("01.the_null_set.song_one.mp3 -> target_file.mp3\n", out)
      assert_empty(err)
    end
  end

  def test_rename_file_exists
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      FileUtils.cp(RES_DIR + 'bad_name.mp3', TMP_DIR)

      assert_raises(Aur::Exception::FileExists) do
        rename_file(f, TMP_DIR + 'bad_name.mp3')
      end
    end
  end

  def test_flipped_suffix
    assert_equal(MP3_TEST, flipped_suffix(FLAC_TEST, 'mp3'))
    assert_equal(FLAC_TEST, flipped_suffix(MP3_TEST, 'flac'))
  end
end

def flac_info
  Aur::FileInfo::Flac.new(FLAC_TEST)
  #  Filename : ../resources/test_tone-100hz.flac
  #      Type : flac
  #   Bitrate : 16-bit/44100Hz
  #    Artist : Test Tones
  #     Album : Test Tones
  #     Title : 100hz
  #     Genre :
  #  Track no : 06
  #      Year :
end

def mp3_info
  Aur::FileInfo::Mp3.new(RES_DIR + '01.the_null_set.song_one.mp3')
  #  Filename : ../resources/01.the_null_set.song_one.mp3
  #      Type : mp3
  #   Bitrate :
  #    Artist :
  #     Album :
  #     Title :
  #     Genre : Alternative
  #  Track no :
  #      Year :
end

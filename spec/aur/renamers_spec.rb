#!/usr/bin/env ruby
# frozen_string_literal: true

require 'ostruct'
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
                 renumbered_file(19, RES_DIR + 'test_tone-100hz.flac'))
  end

  def test_rename_file_ok
    with_test_file('01.test_artist.untagged_song.mp3') do |f|
      out, err = capture_io do
        rename_file(f, TMP_DIR + 'target_file.mp3')
      end

      assert_equal("01.test_artist.untagged_song.mp3 -> target_file.mp3\n", out)
      assert_empty(err)
    end
  end

  def test_rename_file_exists
    with_test_file('01.test_artist.untagged_song.mp3') do |f|
      FileUtils.cp(RES_DIR + 'bad_name.mp3', TMP_DIR)

      assert_output('', "#{TMP_DIR}/bad_name.mp3 already exists\n") do
        rename_file(f, TMP_DIR + 'bad_name.mp3')
      end
    end
  end

  def test_escaped
    assert_equal('"Spiderland"', escaped('Spiderland'))
    assert_equal('"Theme from \"Shaft\""', escaped('Theme from "Shaft"'))
    assert_equal('"\"Loads\" of \"Quotes\""', escaped('"Loads" of "Quotes"'))
  end

  def test_leading_the
    input = OpenStruct.new(
      artist: 'The Someone and The Somethings',
      title: 'The Song',
      album: 'The LP'
    )

    assert_equal('someone_and_the_somethings', artist_fname(input))
    assert_equal('the_song', track_fname(input))
    assert_equal('the_lp', album_fname(input))
  end
end

def flac_info
  Aur::FileInfo.new(RES_DIR + 'test_tone-100hz.flac')
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
  Aur::FileInfo.new(RES_DIR + '01.test_artist.untagged_song.mp3')
  #  Filename : ../resources/01.test_artist.untagged_song.mp3
  #      Type : mp3
  #   Bitrate :
  #    Artist :
  #     Album :
  #     Title :
  #     Genre : Alternative
  #  Track no :
  #      Year :
end

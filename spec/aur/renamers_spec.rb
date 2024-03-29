#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/renamers'
require_relative '../../lib/aur/fileinfo'

# Renaming tests
#
class TestRenamers < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('renamers')

  include Aur::Renamers

  def setup
    @flac = flac_info
    @mp3 = mp3_info
  end

  def test_track_fnum
    assert_equal('06', track_fnum(@flac))
    assert_equal('00', track_fnum(@mp3))
  end

  def test_artist_fname
    assert_equal('test_tones', artist_fname(@flac))
    assert_equal('unknown_artist', artist_fname(@mp3))
  end

  def test_album_fname
    assert_equal('test_tones', album_fname(@flac))
    assert_equal('unknown_album', album_fname(@mp3))
  end

  def test_track_fname
    assert_equal('100hz', track_fname(@flac))
    assert_equal('no_title', track_fname(@mp3))
  end

  def test_file_suffix
    assert_equal('flac', file_suffix(@flac))
    assert_equal('mp3', file_suffix(@mp3))
  end

  def test_renumbered_file
    assert_equal(Pathname.new('/a/03.somefile.flac'),
                 renumbered_file(3, Pathname.new('/a/somefile.flac')))
    assert_equal(Pathname.new('/a/04.somefile.flac'),
                 renumbered_file(4, Pathname.new('/a/02.somefile.flac')))
    assert_equal(Pathname.new('/a/04.band.song.mp3'),
                 renumbered_file(4, Pathname.new('/a/13.band.song.mp3')))
    assert_equal(T_DIR.join('19.test.flac'),
                 renumbered_file(19, T_DIR.join('test.flac')))
  end

  def test_leading_the
    input = TestTags.new({ artist: 'The Someone and The Somethings',
                           title: 'The Song',
                           album: 'The LP',
                           t_num: 2 })

    assert_equal('someone_and_the_somethings', artist_fname(input))
    assert_equal('the_song', track_fname(input))
    assert_equal('the_lp', album_fname(input))
  end

  def test_chars
    input = TestTags.new({ artist: 'The Someone & The Somethings',
                           title: "Hey! What's This? (This & That)",
                           album: '12 Songs & Some Noise',
                           t_num: 5 })

    assert_equal('someone_and_the_somethings', artist_fname(input))
    assert_equal('hey_whats_this--this_and_that', track_fname(input))
    assert_equal('12_songs_and_some_noise', album_fname(input))
  end

  def test_initials
    input = TestTags.new(artist: 'R.E.M.',
                         title: 'R.S.V.P.',
                         album: 'The I.R.S. Years',
                         t_num: 4)

    assert_equal('r-e-m', artist_fname(input))
    assert_equal('r-s-v-p', track_fname(input))
    assert_equal('the_i-r-s_years', album_fname(input))
  end

  def test_slash
    input = TestTags.new(title: 'Reception / Group Therapy')
    assert_equal('reception--group_therapy', track_fname(input))
  end

  private

  def flac_info
    Aur::FileInfo.new(T_DIR.join('test.flac'))
    #  Filename : ../resources/test_tone--100hz.flac
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
    Aur::FileInfo.new(T_DIR.join('01.test_artist.untagged_song.mp3'))
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
end

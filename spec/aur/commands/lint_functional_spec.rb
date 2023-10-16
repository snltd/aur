#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur lint' commands against known entities
#
class TestLintCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'lint')

  def test_good_flac
    assert_silent do
      act(T_DIR.join('tester.correct', '03.tester.good.flac'))
    end
  end

  def test_good_mp3
    assert_silent do
      act(T_DIR.join('tester.correct', '03.tester.good.mp3'))
    end
  end

  def test_missing_tags_and_wrong_album
    file = T_DIR.join('03.test_artist.missing_tags.flac')

    out, err = capture_io { act(file) }
    assert_empty(out)

    assert_match(/#{file}\s+Invalid tag value: t_num/, err)
    assert_match(/#{file}\s+Invalid tag value: genre/, err)
    assert_equal(2, err.lines.count)
  end

  def test_good_flac_with_bad_name
    assert_output('', /Invalid file name$/) { act(T_DIR.join('test.flac')) }
  end

  def test_good_mp3_with_bad_name
    assert_output('', /Invalid file name$/) { act(T_DIR.join('test.mp3')) }
  end

  def test_good_flac_tracks
    assert_silent { act(T_DIR.join('tracks', 'good.tracks_file.flac')) }
    assert_silent { act(T_DIR.join('tracks', 'tester.no_year_is_ok_here.mp3')) }
    assert_silent do
      act(T_DIR.join('tracks', 'tester.no_year_is_ok_here.flac'))
    end
  end

  def test_bom
    assert_output(nil, /Tag has byte order char: title$/) do
      act(T_DIR.join('04.test.has_bom_leader.flac'))
    end
  end

  def test_has_album_tag_tracks
    assert_output(nil, /Invalid tag value: Album tag should not be set$/) do
      act(T_DIR.join('tracks', 'good.album_file.flac'))
    end
  end

  def test_unstripped_tracks
    assert_output(nil, /Unwanted tags: composer, tempo$/) do
      act(T_DIR.join('tracks', 'artist.unstripped.flac'))
    end
  end

  def test_bad_filename_tracks
    assert_output(nil, /Invalid file name$/) do
      act(T_DIR.join('tracks', 'album_file.flac'))
    end

    assert_output(nil, /Invalid file name$/) do
      act(T_DIR.join('tracks', '01.test_artist.incorrect_tags.flac'))
    end
  end

  def test_missing_tags_and_wrong_album_tracks
    file = T_DIR.join('tracks', 'test_artist.missing_tags.flac')
    assert_output(nil, /#{file}\s+Invalid tag value: artist/) { act(file) }
  end

  def test_bitrate
    b_dir = T_DIR.join('bitrate', 'mp3', 'eps', 'tester.test_ep')

    assert_output(nil, /High MP3 bitrate/) do
      act(b_dir.join('01.tester.song.mp3'))
    end

    assert_silent { act(b_dir.join('02.tester.no_flac.mp3')) }
  end

  private

  def act(*files)
    Aur::Action.new(:lint, files).run!
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur lint' commands against known entities
#
class TestLintCommand < MiniTest::Test
  def test_good_flac
    assert_silent do
      act(RES_DIR.join('null_set.some_stuff_by', '03.null_set.high_beam.flac'))
    end
  end

  def test_good_mp3
    assert_silent do
      act(RES_DIR.join('null_set.some_stuff_by', '03.null_set.high_beam.mp3'))
    end
  end

  def test_missing_tags_and_wrong_album
    file = RES_DIR.join('lint', '03.test_artist.missing_tags.flac')

    out, err = capture_io { act(file) }
    assert_empty(out)

    assert_match(/#{file}\s+Invalid tag value: t_num/, err)
    assert_match(/#{file}\s+Invalid tag value: genre/, err)
    assert_equal(2, err.lines.count)
  end

  def test_good_flac_with_bad_name
    assert_output('', /Invalid file name$/) do
      act(RES_DIR.join('test_tone--100hz.flac'))
    end
  end

  def test_good_mp3_with_bad_name
    assert_output('', /Invalid file name$/) do
      act(RES_DIR.join('test_tone--100hz.mp3'))
    end
  end

  T_DIR = RES_DIR.join('lint', 'tracks')

  def test_good_flac_tracks
    assert_silent { act(T_DIR.join('good.tracks_file.flac')) }
    assert_silent { act(T_DIR.join('tester.no_year_is_ok_here.flac')) }
    assert_silent { act(T_DIR.join('tester.no_year_is_ok_here.mp3')) }
  end

  def test_has_album_tag_tracks
    assert_output(nil, /Invalid tag value: Album tag should not be set$/) do
      act(T_DIR.join('good.album_file.flac'))
    end
  end

  def test_unstripped_tracks
    assert_output(nil, /Unwanted tags: composer, tempo$/) do
      act(T_DIR.join('artist.unstripped.flac'))
    end
  end

  def test_bad_filename_tracks
    assert_output(nil, /Invalid file name$/) do
      act(T_DIR.join('album_file.flac'))
    end

    assert_output(nil, /Invalid file name$/) do
      act(T_DIR.join('01.test_artist.incorrect_tags.flac'))
    end
  end

  def test_missing_tags_and_wrong_album_tracks
    file = T_DIR.join('test_artist.missing_tags.flac')
    assert_output(nil, /#{file}\s+Invalid tag value: artist/) { act(file) }
  end

  private

  def act(*files)
    Aur::Action.new(:lint, files).run!
  end
end

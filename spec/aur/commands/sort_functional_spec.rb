#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Tests for sort command
#
class TestSort < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'sort')

  def test_sort_flac
    with_test_file(T_DIR.join('flac')) do |dir|
      assert dir.join('01.band.performance.flac').exist?
      assert dir.join('artist.song.flac').exist?
      assert dir.join('singer.track.flac').exist?

      out, err = capture_io { Aur::Action.new(:sort, dir.children).run! }

      assert_equal(3, out.lines.count)
      assert_match(%r{^artist.song.flac -> artist.album/$}, out)
      assert_match(%r{^01.band.performance.flac -> band.release/$}, out)
      assert_match(%r{^singer.track.flac -> singer.release/$}, out)
      assert_empty(err)

      assert dir.join('band.release', '01.band.performance.flac').exist?
      assert dir.join('artist.album', 'artist.song.flac').exist?
      assert dir.join('singer.release', 'singer.track.flac').exist?

      refute dir.join('01.band.performance.flac').exist?
      refute dir.join('artist.song.flac').exist?
      refute dir.join('singer.track.flac').exist?
    end
  end

  def test_sort_mp3
    with_test_file(T_DIR.join('mp3')) do |dir|
      assert dir.join('01.band.performance.mp3').exist?
      assert dir.join('artist.song.mp3').exist?
      assert dir.join('singer.track.mp3').exist?

      out, err = capture_io { Aur::Action.new(:sort, dir.children).run! }

      assert_equal(3, out.lines.count)
      assert_match(%r{^artist.song.mp3 -> artist.album/$}, out)
      assert_match(%r{^01.band.performance.mp3 -> band.release/$}, out)
      assert_match(%r{^singer.track.mp3 -> singer.release/$}, out)
      assert_empty(err)

      assert dir.join('band.release', '01.band.performance.mp3').exist?
      assert dir.join('artist.album', 'artist.song.mp3').exist?
      assert dir.join('singer.release', 'singer.track.mp3').exist?

      refute dir.join('01.band.performance.mp3').exist?
      refute dir.join('artist.song.mp3').exist?
      refute dir.join('singer.track.mp3').exist?
    end
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/syncflac'

# Tests for syncflac class
#
class TestSyncflac < MiniTest::Test
  def test_difference
    t = Aur::Command::Syncflac.new(RES_DIR.join('syncflac'))

    assert_equal(
      [RES_DIR.join('syncflac/flac/albums/abc/artist.album_1'),
       RES_DIR.join('syncflac/flac/eps/band.ep_1'),
       RES_DIR.join('syncflac/flac/eps/band.ep_2'),
       RES_DIR.join('syncflac/flac/tracks')],
      t.difference(t.flacs, t.mp3s)
    )

    t = Aur::Command::Syncflac.new(RES_DIR.join('lintdir'))

    assert_equal(
      [RES_DIR.join('lintdir/flac/fall.eds_babe'),
       RES_DIR.join('lintdir/flac/slint.spiderland_remastered'),
       RES_DIR.join('lintdir/flac/slint.spiderland_remastered/bonus_disc'),
       RES_DIR.join('lintdir/flac/tester.different_album'),
       RES_DIR.join('lintdir/flac/tester.different_genre'),
       RES_DIR.join('lintdir/flac/tester.different_year')],
      t.difference(t.flacs, t.mp3s)
    )
  end
end

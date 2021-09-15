#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/syncflac'

# Tests for syncflac class
#
class TestSyncflac < MiniTest::Test
  def test_to_be_synced
    t = Aur::Command::Syncflac.new(RES_DIR + 'syncflac')

    assert_equal(
      [RES_DIR + 'syncflac/flac/albums/abc/artist.album_1',
       RES_DIR + 'syncflac/flac/eps/band.ep_1',
       RES_DIR + 'syncflac/flac/eps/band.ep_2',
       RES_DIR + 'syncflac/flac/tracks'],
      t.to_be_synced(t.flacs, t.mp3s)
    )

    t = Aur::Command::Syncflac.new(RES_DIR + 'lintdir')

    assert_equal(
      [RES_DIR + 'lintdir/flac/fall.eds_babe',
       RES_DIR + 'lintdir/flac/slint.spiderland_remastered',
       RES_DIR + 'lintdir/flac/slint.spiderland_remastered/bonus_disc'],
      t.to_be_synced(t.flacs, t.mp3s)
    )
  end
end

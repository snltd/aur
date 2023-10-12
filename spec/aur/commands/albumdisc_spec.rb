#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/albumdisc'

# Tests for Albumdisc
#
class TestAlbumdisc < Minitest::Test
  parallelize_me!

  def setup
    @t = Aur::Command::Albumdisc.new(
      RES_DIR.join('01.test_artist.untagged_song.flac')
    )
  end

  def test_disc_number
    assert_nil @t.disc_number(
      Pathname.new('/a/artist.album/01.artist.song.flac')
    )

    assert_equal(3,
                 @t.disc_number(
                   Pathname.new('/a/artist.album/disc_3/01.artist.song.flac')
                 ))
  end

  def test_new_album
    assert_nil @t.new_album('Album (Disc 1)', 1)
    assert_equal('Album (Disc 1)', @t.new_album('Album', 1))
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur albumdisc' commands against things, and verify the results
#
class TestAlbumdiscCommand < MiniTest::Test
  include Aur::CommandTests

  AT_DIR = RES_DIR + 'albumdisc'

  def _test_albumdisc_single_album
    with_test_file(AT_DIR + 'artist.album' + '01.artist.song.flac') do |f|
      assert_tag(f, :album, 'Album')
      assert_raises(SystemExit) do
        assert_output('ERROR: Bad input: file is not in disc_n directory', '') do
          Aur::Action.new(action, [f]).run!
        end
      end
    end
  end

  def test_albumdisc_has_disc
    with_test_file(AT_DIR + 'artist.double_album') do |f|
      f = f + 'disc_1' + '02.artist.with_disc.flac'
      assert_tag(f, :album, 'Double Album (Disc 1)')
      assert_silent { Aur::Action.new(action, [f]).run! }
      assert_tag(f, :album, 'Double Album (Disc 1)')
    end
  end

  def test_albumdisc_needs_disc
    with_test_file(AT_DIR + 'artist.double_album') do |f|
      f = f + 'disc_1' + '01.artist.without_disc.flac'
      assert_tag(f, :album, 'Double Album')

      assert_output("       album -> Double Album (Disc 1)\n", nil) do
        Aur::Action.new(action, [f]).run!
      end

      assert_tag(f, :album, 'Double Album (Disc 1)')
    end
  end

  def action
    :albumdisc
  end
end

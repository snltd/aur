#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur artfix' commands against a mock filesystem, and verify the results.
#
class TestArtfixCommand < MiniTest::Test
  def test_directory_nothing_to_do
    out, err = capture_io { act(MDIR, FDIR) }
    assert_empty(out)
    assert_empty(err)
  end

  def test_artfix_noop
    out, err = capture_io do
      Aur::Action.new(:artfix, [], { '<directory>': [AFDIR], noop: true }).run!
    end

    assert_equal(expected_output(AFDIR), out)
    assert_empty(err)
    assert (AFDIR + 'albums/jesus_lizard.liar/cover.jpg').exist?
    refute (AFDIR + 'albums/jesus_lizard.liar/front.jpg').exist?
  end

  def test_artfix
    with_test_file(AFDIR) do |dir|
      out, err = capture_io do
        Aur::Action.new(:artfix, [], { '<directory>': [dir] }).run!
      end

      assert_equal(expected_output(dir), out)
      assert_empty(err)

      refute (dir + 'albums/jesus_lizard.liar/cover.jpg').exist?
      assert (dir + 'albums/jesus_lizard.liar/front.jpg').exist?

      refute (dir + 'albums/windy_and_carl.portal/Front.jpg').exist?
      assert (dir + 'albums/windy_and_carl.portal/front.jpg').exist?

      refute (dir + 'eps/water_world.dead/front cover.Png').exist?
      assert (dir + 'eps/water_world.dead/front.png').exist?
    end
  end

  private

  def act(*dirs)
    Aur::Action.new(:artfix, [], { '<directory>': dirs }).run!
  end

  def expected_output(dir)
    <<~EOOUT
      renaming #{dir}/albums/jesus_lizard.liar/cover.jpg -> front.jpg
      renaming #{dir}/albums/windy_and_carl.portal/Front.JPG -> front.jpg
      renaming #{dir}/eps/water_world.dead/front cover.Png -> front.png
    EOOUT
  end
end

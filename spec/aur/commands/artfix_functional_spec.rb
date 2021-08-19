#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur artfix' commands against a mock filesystem, and verify the results.
#
class TestArtfixCommand < MiniTest::Test
  def test_directory_nothing_to_do
    assert_silent do
      act(RES_DIR + 'lintdir' + 'flac',
          RES_DIR + 'lintdir' + 'mp3')
    end
  end

  def test_artfix_noop
    assert_output(expected_output(RES_DIR + 'artfix'), '') do
      Aur::Action.new(:artfix, [],
                      { '<directory>': [RES_DIR + 'artfix'], noop: true }).run!
    end

    assert (RES_DIR + 'artfix/albums/jesus_lizard.liar/cover.jpg').exist?
    refute (RES_DIR + 'artfix/albums/jesus_lizard.liar/front.jpg').exist?
  end

  def test_artfix
    with_test_file(RES_DIR + 'artfix') do |dir|
      assert_output(expected_output(dir), '') do
        Aur::Action.new(:artfix, [], { '<directory>': [dir] }).run!
      end

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

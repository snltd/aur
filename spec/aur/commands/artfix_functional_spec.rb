#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fastimage'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur artfix' commands against a mock filesystem, and verify the results.
#
class TestArtfixCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'artfix')

  def test_directory_nothing_to_do
    assert_silent { act(nil, T_DIR.join('eps', 'test.good_art')) }
  end

  def test_artfix_rename_only
    with_test_file(T_DIR) do |dir|
      tdir = dir.join('albums', 'test.wrong_name')
      assert tdir.join('cover.jpg').exist?
      refute tdir.join('front.jpg').exist?

      assert_output(
        "renaming #{tdir}/cover.jpg -> front.jpg\n" \
        "resizing #{tdir}/front.jpg\n",
        nil
      ) do
        act(nil, tdir)
      end

      refute tdir.join('cover.jpg').exist?
      assert tdir.join('front.jpg').exist?
    end
  end

  def test_artfix_rename_and_resize
    with_test_file(T_DIR) do |dir|
      tdir = dir.join('albums', 'test.wrong_name--wrong_size')

      assert tdir.join('Front.JPG').exist?
      refute tdir.join('front.jpg').exist?

      x, y = FastImage.size(tdir.join('Front.JPG'))

      assert_equal(900, x)
      assert_equal(900, y)

      assert_output("renaming #{tdir}/Front.JPG -> front.jpg\n" \
                    "resizing #{tdir}/front.jpg\n",
                    nil) do
        act(nil, tdir)
      end

      assert tdir.join('front.jpg').exist?
      refute tdir.join('Front.JPG').exist?

      x, y = FastImage.size(tdir.join('front.jpg'))
      assert_equal(700, x)
      assert_equal(700, y)
    end
  end

  def test_artfix_not_square
    with_test_file(T_DIR) do |dir|
      link_dir = dir.join('target')
      tdir = dir.join('albums', 'test.wrong_name--not_square')
      assert tdir.join('cover.jpg').exist?
      refute tdir.join('front.jpg').exist?
      refute link_dir.exist?

      assert_output(
        "renaming #{tdir}/cover.jpg -> front.jpg\n" \
        "linking #{tdir}/front.jpg to #{link_dir}\n",
        nil
      ) do
        act(link_dir, tdir)
      end

      refute tdir.join('cover.jpg').exist?
      assert tdir.join('front.jpg').exist?
      assert link_dir.exist?

      path_prefix = link_dir.parent.to_s[1..].tr('/', '-')

      assert link_dir.join(
        "#{path_prefix}-albums-test.wrong_name--not_square-front.jpg"
      ).exist?
    end
  end

  private

  def act(link_dir, *dirs)
    Aur::Action.new(
      :artfix,
      [],
      { '<directory>': dirs, linkdir: link_dir }
    ).run!
  end
end

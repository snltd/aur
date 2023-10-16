#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../../spec_helper'
require_relative '../../../../lib/aur/commands/mixins/file_tree'

# Tests for FileTree mixin
#
class Test < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'mixins', 'file_tree')

  include Aur::Mixin::FileTree

  def test_content_under
    assert_equal(
      [
        [Pathname.new('flac/albums/abc/band.album'), 6],
        [Pathname.new('flac/albums/abc/band.album/bonus_disc'), 3],
        [Pathname.new('flac/eps/test.some_ep'), 4],
        [Pathname.new('flac/albums/tuv/tester.first_album'), 5],
        [Pathname.new('flac/albums/tuv/tester.second_album'), 3],
        [Pathname.new('flac/albums/tuv/tester.third_album'), 7]
      ].sort,
      content_under(T_DIR, '.flac').sort
    )

    assert_equal([], content_under(T_DIR, '.mp3'))
  end

  def test_files_under
    result = files_under(T_DIR, '.flac')

    assert_instance_of(Hash, result)
    assert_equal(28, result.size)
    assert(result.all? { |k, v| k.is_a?(Pathname) && v.is_a?(String) })

    assert_equal(
      'test.song_1.flac',
      result[T_DIR.join('flac', 'eps', 'test.some_ep', '01.test.song_1.flac')]
    )
  end

  def test_dirs_under
    ep_path = T_DIR.join('flac', 'eps', 'test.some_ep')

    all = dirs_under(T_DIR.join('flac'))
    assert all.all?(&:directory?)
    assert_includes(all, ep_path)

    selected = dirs_under(T_DIR, [ep_path])
    assert selected.all?(&:directory?)
    refute_includes(selected, ep_path)
  end
end

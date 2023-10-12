#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../../spec_helper'
require_relative '../../../../lib/aur/commands/mixins/file_tree'

# Tests for FileTree mixin
#
class Test < Minitest::Test
  parallelize_me!

  include Aur::Mixin::FileTree

  TEST_DIR = RES_DIR.join('lintdir', 'flac')

  def test_content_under
    assert_equal(
      [
        [Pathname.new('fall.eds_babe'), 4],
        [Pathname.new('slint.spiderland_remastered'), 6],
        [Pathname.new('slint.spiderland_remastered/bonus_disc'), 14],
        [Pathname.new('tester.different_album'), 3],
        [Pathname.new('tester.different_genre'), 3],
        [Pathname.new('tester.different_year'), 3]
      ],
      content_under(TEST_DIR, '.flac')
    )

    assert_equal([], content_under(TEST_DIR, '.mp3'))
  end

  def test_files_under
    result = files_under(TEST_DIR, '.flac')

    assert_instance_of(Hash, result)
    assert_equal(33, result.size)
    assert(result.all? { |k, v| k.is_a?(Pathname) && v.is_a?(String) })
    assert_equal(
      TEST_DIR.join('fall.eds_babe', '04.fall.free_ranger.flac'),
      result.key('fall.free_ranger.flac')
    )
  end

  def test_dirs_under
    all = dirs_under(TEST_DIR)
    assert all.all?(&:directory?)
    assert_includes(all, TEST_DIR.join('fall.eds_babe'))

    selected = dirs_under(TEST_DIR, ['fall.eds_babe'])
    assert selected.all?(&:directory?)
    refute_includes(selected, TEST_DIR.join('fall.eds_babe'))
  end
end

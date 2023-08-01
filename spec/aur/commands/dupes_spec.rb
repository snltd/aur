#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/dupes'

# Run a dupe test
#
class TestDupes < Minitest::Test
  TEST_DIR = RES_DIR.join('dupes')
  F_DIR = TEST_DIR.join('flac')
  T_DIR = F_DIR.join('tracks')

  def test_find_dupes
    t = Aur::Command::Dupes.new(TEST_DIR)
    result = t.find_dupes(t.all_flacs)

    assert_equal(2, result.count)

    f_res = result[T_DIR.join('fall.free_ranger.flac')]
    assert_equal(
      [
        Pathname.new(
          F_DIR.join('eps', 'fall.eds_babe', '04.fall.free_ranger.flac')
        ),
        Pathname.new(
          F_DIR.join('eps', 'various.compilation', '11.fall.free_ranger.flac')
        )
      ],
      f_res
    )

    assert_equal(1, result[T_DIR.join('slint.don_aman.flac')].size)
  end
end

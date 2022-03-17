#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/dupes'

# Run a dupe test
#
class TestDupes < MiniTest::Test
  TEST_DIR = RES_DIR + 'dupes'
  F_DIR = TEST_DIR + 'flac'
  T_DIR = F_DIR + 'tracks'

  def test_find_dupes
    t = Aur::Command::Dupes.new(TEST_DIR)
    result = t.find_dupes(t.all_flacs)

    assert_equal(2, result.count)

    f_res = result[T_DIR + 'fall.free_ranger.flac']
    assert_equal(
      [
        Pathname.new(
          F_DIR + 'eps' + 'fall.eds_babe' + '04.fall.free_ranger.flac'
        ),
        Pathname.new(
          F_DIR + 'eps' + 'various.compilation' + '11.fall.free_ranger.flac'
        )
      ],
      f_res
    )

    assert_equal(1, result[T_DIR + 'slint.don_aman.flac'].size)
  end
end

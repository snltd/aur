#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/dupes'

# Run a dupe test
#
class TestDupes < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'dupes')

  def test_find_dupes
    t = Aur::Command::Dupes.new(T_DIR)
    result = t.find_dupes(t.all_flacs)

    assert_equal(2, result.count)

    f_res = result[T_DIR.join('flac', 'tracks', 'fall.free_ranger.flac')]
    assert_equal(
      [
        Pathname.new(
          T_DIR.join(
            'flac', 'eps', 'fall.eds_babe', '04.fall.free_ranger.flac'
          )
        ),
        Pathname.new(
          T_DIR.join(
            'flac', 'eps', 'various.compilation', '11.fall.free_ranger.flac'
          )
        )
      ],
      f_res
    )

    assert_equal(
      1,
      result[T_DIR.join('flac', 'tracks', 'slint.don_aman.flac')].size
    )
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/helpers'

# Tests for helper methods
#
class TestHelpers < Minitest::Test
  include Aur::Helpers

  parallelize_me!

  T_DIR = RES_DIR.join('helpers', 'dirs')

  def test_escaped
    assert_equal('"Spiderland"', escaped('Spiderland'))
    assert_equal('"Theme from \"Shaft\""', escaped('Theme from "Shaft"'))
    assert_equal('"\"Loads\" of \"Quotes\""', escaped('"Loads" of "Quotes"'))
  end

  def test_recursive_dir_list
    assert_equal(lintdirs, Aur::Helpers.recursive_dir_list([T_DIR]).sort)

    assert_equal(
      lintdirs,
      Aur::Helpers.recursive_dir_list(
        [T_DIR, T_DIR.join('flac'), T_DIR.join('mp3')]
      ).sort
    )
  end

  def test_format_time
    assert_equal('0:45', format_time(45))
    assert_equal('0.3', format_time(0.3))
    assert_equal('1:13', format_time(73.5))
    assert_equal('1:04:36', format_time(3876))
  end

  private

  def lintdirs
    [T_DIR,
     T_DIR.join('flac'),
     T_DIR.join('flac', 'eps'),
     T_DIR.join('flac', 'eps', 'band.ep_1'),
     T_DIR.join('flac', 'eps', 'band.ep_2'),
     T_DIR.join('flac', 'albums'),
     T_DIR.join('flac', 'albums', 'abc'),
     T_DIR.join('flac', 'albums', 'pqrs'),
     T_DIR.join('flac', 'albums', 'abc', 'artist.lp'),
     T_DIR.join('flac', 'albums', 'pqrs', 'singer.album'),
     T_DIR.join('flac', 'albums', 'pqrs', 'singer.album', 'bonus_disc'),
     T_DIR.join('mp3'),
     T_DIR.join('mp3', 'eps'),
     T_DIR.join('mp3', 'eps', 'band.ep_1')].sort
  end
end

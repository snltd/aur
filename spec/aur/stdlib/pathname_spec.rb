#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/stdlib/pathname'

# Tests for Pathname extentions
#
class TestPathname < Minitest::Test
  parallelize_me!

  def test_extclass
    assert_equal('Flac', Pathname.new('file.flac').extclass)
    assert_equal('Mp3', Pathname.new('file.mp3').extclass)
    assert_equal('Jpg', Pathname.new('file.jpg').extclass)
  end

  def test_prefixed
    assert_equal(RES_DIR.join('_test_tone--100hz.flac'),
                 RES_DIR.join('test_tone--100hz.flac').prefixed)
    assert_equal(RES_DIR.join('xxtest_tone--100hz.flac'),
                 RES_DIR.join('test_tone--100hz.flac').prefixed('xx'))
  end

  def test_no_tnum
    assert_equal('slint.washer.flac',
                 Pathname.new('/dir/04.slint.washer.flac').no_tnum)
    assert_equal('slint.washer.mp3',
                 Pathname.new('/dir/04.slint.washer.mp3').no_tnum)
    assert_equal('slint.washer.flac',
                 Pathname.new('/dir/slint.washer.flac').no_tnum)
  end
end

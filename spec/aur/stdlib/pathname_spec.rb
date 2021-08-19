#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/stdlib/pathname'

# Tests for Pathname extentions
#
class TestPathname < MiniTest::Test
  def test_extclass
    assert_equal('Flac', Pathname.new('file.flac').extclass)
    assert_equal('Mp3', Pathname.new('file.mp3').extclass)
    assert_equal('Jpg', Pathname.new('file.jpg').extclass)
  end

  def test_prefixed
    assert_equal(RES_DIR + '_test_tone-100hz.flac',
                 (RES_DIR + 'test_tone-100hz.flac').prefixed)
    assert_equal(RES_DIR + 'xxtest_tone-100hz.flac',
                 (RES_DIR + 'test_tone-100hz.flac').prefixed('xx'))
  end
end

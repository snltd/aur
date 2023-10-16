#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/renumber'

# Tests for Renumber class
#
class TestRenumber < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'renumber')

  def test_validate_mp3
    t = Aur::Command::Renumber.new(T_DIR.join('test.mp3'))

    assert_equal(5, t.validate('5'))
    assert_raises(Aur::Exception::InvalidValue) { t.validate('0') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('-5') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('xxxx') }
  end

  def test_validate_flac
    t = Aur::Command::Renumber.new(T_DIR.join('test.flac'))

    assert_equal(5, t.validate('5'))
    assert_raises(Aur::Exception::InvalidValue) { t.validate('0') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('-5') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('xxxx') }
  end
end

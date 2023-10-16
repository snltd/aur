#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/renumber'

# Tests for Renumber class
#
class TestRenumber < Minitest::Test
  parallelize_me!

  def test_validate_mp3
    t = Aur::Command::Renumber.new(UNIT_MP3)

    assert_equal(5, t.validate('5'))
    assert_raises(Aur::Exception::InvalidValue) { t.validate('0') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('-5') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('xxxx') }
  end

  def test_validate_flac
    t = Aur::Command::Renumber.new(UNIT_FLAC)

    assert_equal(5, t.validate('5'))
    assert_raises(Aur::Exception::InvalidValue) { t.validate('0') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('-5') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('xxxx') }
  end
end

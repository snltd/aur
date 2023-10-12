#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/renumber'

# Tests
#
class TestRenumber < Minitest::Test
  parallelize_me!

  def test_validate
    t = Aur::Command::Renumber.new(RES_DIR.join('test_tone--100hz.flac'))

    assert_equal(5, t.validate('5'))

    assert_raises(Aur::Exception::InvalidValue) { t.validate('0') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('-5') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('xxxx') }
  end
end

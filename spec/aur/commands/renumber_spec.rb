#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/renumber'

# Tests
#
class TestRenumber < MiniTest::Test
  def test_validate
    t = Aur::Command::Renumber.new(FLAC_TEST)

    assert_equal(5, t.validate('5'))

    assert_raises(Aur::Exception::InvalidValue) { t.validate('0') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('-5') }
    assert_raises(Aur::Exception::InvalidValue) { t.validate('xxxx') }
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/stdlib/numeric'

# Tests for extensions to Numeric class
#
class TestNumeric < MiniTest::Test
  def test_to_n
    assert_equal('02', 2.to_n)
    assert_equal('99', 99.to_n)
    assert_equal('04', 0o4.to_n)
    assert_equal('123', 123.to_n)
  end
end

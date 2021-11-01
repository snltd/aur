#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/aur/helpers'

# Tests
#
class Test < MiniTest::Test
  include Aur::Helpers

  def test_escaped
    assert_equal('"Spiderland"', escaped('Spiderland'))
    assert_equal('"Theme from \"Shaft\""', escaped('Theme from "Shaft"'))
    assert_equal('"\"Loads\" of \"Quotes\""', escaped('"Loads" of "Quotes"'))
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/inumber'

# Tests
#
class TestInumber < MiniTest::Test
  attr_reader :totest

  def setup
    @totest = Aur::Command::Inumber.new(RES_DIR + 'test_tone-100hz.flac')
  end

  def test_validate
    assert_equal(5, totest.validate('5'))
    assert_equal(1, totest.validate('1'))
    assert_equal(19, totest.validate('19'))

    assert_raises(Aur::Exception::InvalidInput) { totest.validate('') }
    assert_raises(Aur::Exception::InvalidInput) { totest.validate('-1') }
    assert_raises(Aur::Exception::InvalidInput) { totest.validate('a') }
  end
end

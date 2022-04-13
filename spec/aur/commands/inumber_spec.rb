#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/inumber'

# Tests for interactive numbering
#
class TestInumber < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::Command::Inumber.new(RES_DIR + 'test_tone-100hz.flac')
  end

  def test_validate
    assert_equal(5, t.validate('5'))
    assert_equal(1, t.validate('1'))
    assert_equal(19, t.validate('19'))

    assert_raises(Aur::Exception::InvalidInput) { t.validate('') }
    assert_raises(Aur::Exception::InvalidInput) { t.validate('-1') }
    assert_raises(Aur::Exception::InvalidInput) { t.validate('a') }
  end
end

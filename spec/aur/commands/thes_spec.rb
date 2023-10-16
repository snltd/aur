#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/thes'

# Test for thes command
#
class TestThes < Minitest::Test
  def test_new_name
    t = Aur::Command::Thes.new(UNIT_FLAC)

    assert_equal('The B-52s', t.new_name('B-52s'))
    refute(t.new_name('The B-52s'))
    refute(t.new_name('The The'))
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/stdlib/array'

# Tests for extensions to Array class
#
class TestArray < MiniTest::Test
  def test_to_paths
    assert_equal([Pathname.new('/etc/passwd'), Pathname.new('/etc/hosts')],
                 %w[/etc/passwd /etc/hosts].to_paths)
  end
end

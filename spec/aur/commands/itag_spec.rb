#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/itag'

# Tests for interactive tagging
#
class TestItag < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'itag')

  def test_valid_tag?
    t = Aur::Command::Itag.new(T_DIR.join('test.flac'))

    assert t.valid_tag?(:title)
    assert t.valid_tag?(:t_num)
    assert_raises(Aur::Exception::InvalidTagName) { t.valid_tag?(:number) }
  end
end

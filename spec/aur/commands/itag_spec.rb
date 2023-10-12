#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/itag'

# Tests for interactive tagging
#
class TestItag < Minitest::Test
  parallelize_me!

  def setup
    @t = Aur::Command::Itag.new(RES_DIR.join('test_tone--100hz.flac'))
  end

  def test_valid_tag?
    assert @t.valid_tag?(:title)
    assert @t.valid_tag?(:t_num)
    assert_raises(Aur::Exception::InvalidTagName) { @t.valid_tag?(:number) }
  end
end

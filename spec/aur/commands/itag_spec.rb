#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/itag'

# Tests for interactive tagging
#
class TestItag < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::Command::Itag.new(RES_DIR + 'test_tone-100hz.flac')
  end

  def test_valid_tag?
    assert t.valid_tag?(:title)
    assert t.valid_tag?(:t_num)
    assert_raises(Aur::Exception::InvalidTagName) { t.valid_tag?(:number) }
  end
end

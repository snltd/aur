#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/itag'

# Tests for interactive tagging
#
class TestItag < Minitest::Test
  parallelize_me!

  def test_flac_valid_tag?
    t = Aur::Command::Itag.new(UNIT_FLAC)
    assert t.valid_tag?(:title)
    assert t.valid_tag?(:t_num)
    assert_raises(Aur::Exception::InvalidTagName) { t.valid_tag?(:number) }
  end

  def test_mp3_valid_tag?
    t = Aur::Command::Itag.new(UNIT_MP3)
    assert t.valid_tag?(:title)
    assert t.valid_tag?(:t_num)
    assert_raises(Aur::Exception::InvalidTagName) { t.valid_tag?(:number) }
  end
end

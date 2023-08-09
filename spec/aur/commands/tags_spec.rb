#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/tags'

# Test tags command
#
class TestTagsCmd < Minitest::Test
  attr_reader :flac

  def setup
    @flac = Aur::Command::Tags.new(RES_DIR.join('test_tone--100hz.flac'))
  end

  def test_fmt_line
    assert_equal(' Artist : Test Tones',
                 flac.fmt_line(:Artist, 'Test Tones', 7))
  end
end

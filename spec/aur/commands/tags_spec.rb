#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/tags'

# Test tags command
#
class TestTagsCmd < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'tags')

  def test_fmt_line
    flac = Aur::Command::Tags.new(T_DIR.join('test.flac'))

    assert_equal(' Artist : Test Tones',
                 flac.fmt_line(:Artist, 'Test Tones', 7))
  end
end

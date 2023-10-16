#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/reencode'

# Test for reencode internals
#
class TestReencode < Minitest::Test
  def test_construct_cmd
    f = UNIT_FLAC
    t = Aur::Command::Reencode.new(f)

    assert_equal(
      "#{BIN[:ffmpeg]} -hide_banner -loglevel error -i \"#{f}\" " \
      "-compression_level 8 \"#{f.dirname}/_#{f.basename}\"",
      t.construct_cmd(f, f.prefixed)
    )
  end
end

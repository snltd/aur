#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/reencode'
require_relative '../../../lib/aur/stdlib/pathname'

# Test for reencode internals
#
class TestReencode < MiniTest::Test
  def test_construct_cmd
    t = Aur::Command::Reencode.new(RES_DIR.join('test_tone--100hz.flac'))

    assert_equal(
      "#{BIN[:ffmpeg]} -hide_banner -loglevel error -i " \
      "\"#{RES_DIR}/test_tone--100hz.flac\" " \
      "\"#{RES_DIR}/_test_tone--100hz.flac\"",
      t.construct_cmd(RES_DIR.join('test_tone--100hz.flac'),
                      RES_DIR.join('test_tone--100hz.flac').prefixed)
    )
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/transcode'
require_relative '../../../lib/aur/stdlib/pathname'

# Test for transcode internals
#
class TestTranscode < Minitest::Test
  def test_construct_cmd
    t = Aur::Command::Transcode.new(UNIT_FLAC)

    assert_equal(
      "#{BIN_DIR}/ffmpeg -hide_banner -loglevel panic -i \"#{UNIT_FLAC}\" " \
      "\"#{UNIT_MP3}\"",
      t.construct_cmd(UNIT_FLAC, UNIT_MP3)
    )
  end
end

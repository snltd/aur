#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/transcode'
require_relative '../../../lib/aur/stdlib/pathname'

# Test for transcode internals
#
class TestTranscode < MiniTest::Test
  def test_construct_cmd
    t = Aur::Command::Transcode.new(FLAC_TEST)

    assert_equal(
      '/opt/sysdef/ffmpeg/bin/ffmpeg -hide_banner -loglevel error -i ' \
      "\"#{RES_DIR}/test_tone-100hz.flac\" " \
      "\"#{RES_DIR}/test_tone-100hz.mp3\"",
      t.construct_cmd(FLAC_TEST, MP3_TEST)
    )
  end
end

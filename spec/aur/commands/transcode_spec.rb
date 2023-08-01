#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/transcode'
require_relative '../../../lib/aur/stdlib/pathname'

# Test for transcode internals
#
class TestTranscode < Minitest::Test
  def test_construct_cmd
    t = Aur::Command::Transcode.new(RES_DIR.join('test_tone--100hz.flac'))

    assert_equal(
      '/opt/ooce/bin/ffmpeg -hide_banner -loglevel panic -i ' \
      "\"#{RES_DIR}/test_tone--100hz.flac\" " \
      "\"#{RES_DIR}/test_tone--100hz.mp3\"",
      t.construct_cmd(RES_DIR.join('test_tone--100hz.flac'),
                      RES_DIR.join('test_tone--100hz.mp3'))
    )
  end
end

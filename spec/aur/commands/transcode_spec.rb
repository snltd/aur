#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/transcode'
require_relative '../../../lib/aur/stdlib/pathname'

# Test for transcode internals
#
class TestTranscode < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'transcode')

  def test_construct_cmd
    t = Aur::Command::Transcode.new(T_DIR.join('test.flac'))

    assert_equal(
      "#{BIN_DIR}/ffmpeg -hide_banner -loglevel panic -i " \
      "\"#{T_DIR.join('test.flac')}\" " \
      "\"#{T_DIR.join('test.mp3')}\"",
      t.construct_cmd(T_DIR.join('test.flac'), T_DIR.join('test.mp3'))
    )
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/cdq'

# Test for cdq internals
#
class TestCdq < Minitest::Test
  parallelize_me!

  def test_construct_cmd
    t = Aur::Command::Cdq.new(RES_DIR.join('test_tone--100hz.flac'))

    assert_equal(
      "#{BIN_DIR}/ffmpeg -hide_banner -loglevel error " \
      "-i \"#{RES_DIR}/test_tone--100hz.flac\" " \
      '-af aresample=out_sample_fmt=s16:out_sample_rate=44100 ' \
      "\"#{RES_DIR}/intermediate-file.flac\"",
      t.construct_cmd(RES_DIR.join('test_tone--100hz.flac'),
                      RES_DIR.join('intermediate-file.flac'))
    )
  end
end

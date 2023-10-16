#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/cdq'

# Test for cdq internals
#
class TestCdq < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'cdq')

  def test_construct_cmd
    t = Aur::Command::Cdq.new(T_DIR.join('test.flac'))

    assert_equal(
      "#{BIN_DIR}/ffmpeg -hide_banner -loglevel error " \
      "-i \"#{T_DIR}/test.flac\" " \
      '-af aresample=out_sample_fmt=s16:out_sample_rate=44100 ' \
      "\"#{T_DIR}/intermediate-file.flac\"",
      t.construct_cmd(T_DIR.join('test.flac'),
                      T_DIR.join('intermediate-file.flac'))
    )
  end
end

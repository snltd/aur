#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/cdq'

# Test for cdq internals
#
class TestCdq < Minitest::Test
  def test_construct_cmd
    t = Aur::Command::Cdq.new(UNIT_FLAC)

    intermediate = UNIT_FLAC.parent.join('intermediate-file.flac')

    assert_equal(
      "#{BIN_DIR}/ffmpeg -hide_banner -loglevel error -i \"#{UNIT_FLAC}\" " \
      '-af aresample=out_sample_fmt=s16:out_sample_rate=44100 ' \
      "\"#{intermediate}\"",
      t.construct_cmd(UNIT_FLAC, intermediate)
    )
  end
end

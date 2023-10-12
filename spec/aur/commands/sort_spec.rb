#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/sort'

# Tests for sort command
#
class TestSort < Minitest::Test
  parallelize_me!

  def test_run
    t = Aur::Command::Sort.new(RES_DIR.join('test_tone--100hz.flac'))
    mv = Spy.on(FileUtils, :mv)
    mkdir = Spy.on(FileUtils, :mkdir_p)
    assert_output("test_tone--100hz.flac -> test_tones.test_tones/\n", '') do
      t.run
    end

    assert(mv.has_been_called?)
    assert_equal([RES_DIR.join('test_tone--100hz.flac'),
                  RES_DIR.join('test_tones.test_tones',
                               'test_tone--100hz.flac')],
                 mv.calls.first.args)
    assert(mkdir.has_been_called?)
    assert_equal([RES_DIR.join('test_tones.test_tones')],
                 mkdir.calls.first.args)
  end
end

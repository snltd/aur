#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/sort'

# Tests for sort command
#
class TestSort < MiniTest::Test
  def test_run
    t = Aur::Command::Sort.new(FLAC_TEST)
    mv = Spy.on(FileUtils, :mv)
    mkdir = Spy.on(FileUtils, :mkdir_p)
    assert_output("test_tone-100hz.flac -> test_tones.test_tones/\n", '') do
      t.run
    end

    assert(mv.has_been_called?)
    assert_equal([FLAC_TEST, RES_DIR + 'test_tones.test_tones' +
                  FLAC_TEST.basename],
                 mv.calls.first.args)
    assert(mkdir.has_been_called?)
    assert_equal([RES_DIR + 'test_tones.test_tones'], mkdir.calls.first.args)
  end
end

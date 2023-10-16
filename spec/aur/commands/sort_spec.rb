#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/sort'

# Tests for sort command. Don't parallelize -- it breaks Spy.
#
class TestSort < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'sort')

  def test_run
    t = Aur::Command::Sort.new(T_DIR.join('test.flac'))

    mv = Spy.on(FileUtils, :mv)
    mkdir = Spy.on(FileUtils, :mkdir_p)
    assert_output("test.flac -> test_tones.test_tones/\n", '') do
      t.run
    end

    assert(mv.has_been_called?)
    assert_equal([T_DIR.join('test.flac'),
                  T_DIR.join('test_tones.test_tones',
                             'test.flac')],
                 mv.calls.first.args)
    assert(mkdir.has_been_called?)
    assert_equal([T_DIR.join('test_tones.test_tones')],
                 mkdir.calls.first.args)
  end
end

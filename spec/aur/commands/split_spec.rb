#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/split'

# Tests
#
class SplitTest < MiniTest::Test
  def test_cuefile
    totest = Aur::Split::Generic.new(FLAC_TEST)
    assert_equal(Pathname.new(RES_DIR + 'test_tone-100hz.cue'), totest.cuefile)
  end
end

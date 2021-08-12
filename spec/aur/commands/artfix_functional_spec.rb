#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur artfix' commands against a mock filesystem, and verify the results.
#
class TestArtfixCommand < MiniTest::Test
  def test_directory_nothing_to_do
    out, err = capture_io { act(MDIR, FDIR) }
    assert_empty(out)
    assert_empty(err)
  end

  private

  def act(*dirs)
    Aur::Action.new(:artfix, [], { '<directory>': dirs }).run!
  end
end

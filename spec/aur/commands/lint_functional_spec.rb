#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur lint' commands against known entities
#
class TestLintCommand < MiniTest::Test
  def test_good_flac
    # assert_silent { act(FLAC_TEST) }
  end

  def test_good_mp3
    # assert_silent { act(TEST_FLAC) }
  end

  private

  def act(*files)
    Aur::Action.new(:lint, files).run!
  end
end

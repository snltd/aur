#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/constants'

# Run 'aur verify' commands against things, and verify the output
#
class TestVerifyCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'verify')

  attr_reader :dir

  include Aur::CommandTests

  def test_verify_nothing
    assert_output('', "No valid files supplied.\n") do
      Aur::Action.new(:verify, [T_DIR.join('front.png')]).run!
    end
  end

  def test_flac_verify
    assert_output(/good_file.flac\s+OK$/, '') do
      Aur::Action.new(:verify, [T_DIR.join('good_file.flac')]).run!
    end
  end

  def action = :verify
end

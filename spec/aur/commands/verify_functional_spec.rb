#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/constants'

# Run 'aur verify' commands against things, and verify the output
#
class TestVerifyCmd < Minitest::Test
  parallelize_me!

  attr_reader :dir

  include Aur::CommandTests

  def test_verify_nothing
    assert_output('', "No valid files supplied.\n") do
      Aur::Action.new(:verify, [RES_DIR.join('front.png')]).run!
    end
  end

  def test_flac_verify
    assert_output(/bad_name.flac\s+OK$/, '') do
      Aur::Action.new(:verify, [RES_DIR.join('bad_name.flac')]).run!
    end
  end

  def action
    :verify
  end
end

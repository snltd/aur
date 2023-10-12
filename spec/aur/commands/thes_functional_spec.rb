#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur thes' commands against things, and verify the results
#
class TestThesCommand < Minitest::Test
  parallelize_me!

  include Aur::CommandTests

  def test_flac_thes
    SUPPORTED_TYPES.each do |type|
      with_test_file("test_tone--100hz.#{type}") do |f|
        assert_tag(f, :artist, 'Test Tones')

        assert_output("      artist -> The Test Tones\n", '') do
          Aur::Action.new(:thes, [f]).run!
        end

        assert_tag(f, :artist, 'The Test Tones')

        assert_output('', '') { Aur::Action.new(:thes, [f]).run! }

        assert_tag(f, :artist, 'The Test Tones')
      end
    end
  end

  def action
    :thes
  end
end

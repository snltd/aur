#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur thes' commands against things, and verify the results
#
class TestThesCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'thes')

  include Aur::CommandTests

  def test_flac_thes
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("test.#{type}")
        assert_tag(f, :artist, 'Test Tones')

        assert_output("      artist -> The Test Tones\n", '') do
          Aur::Action.new(action, [f]).run!
        end

        assert_tag(f, :artist, 'The Test Tones')

        assert_output('', '') { Aur::Action.new(action, [f]).run! }

        assert_tag(f, :artist, 'The Test Tones')
      end
    end
  end

  def action = :thes
end

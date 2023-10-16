#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur num2name' commands against things, and verify the results
#
class TestNum2NameCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'num2name')

  include Aur::CommandTests

  def test_num2name
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("bad_name.#{type}")
        expected_file = f.parent.join("02.bad_name.#{type}")
        refute(expected_file.exist?)

        assert_output("bad_name.#{type} -> 02.bad_name.#{type}\n", '') do
          Aur::Action.new(action, [f]).run!
        end

        refute(f.exist?)
        assert(expected_file.exist?)

        out, err = capture_io { Aur::Action.new(action, [expected_file]).run! }

        assert_empty(err)
        assert_equal("No change required.\n", out)
      end
    end
  end

  def test_num2name_no_number_tag
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("test.#{type}")
        target = f.parent.join("06.test.#{type}")

        assert f.exist?
        refute target.exist?

        assert_output("#{f.basename} -> #{target.basename}\n", '') do
          Aur::Action.new(action, [f]).run!
        end

        refute f.exist?
        assert target.exist?
      end
    end
  end

  def action = :num2name
end

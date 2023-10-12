#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur num2name' commands against things, and verify the results
#
class TestNum2NameCommand < Minitest::Test
  include Aur::CommandTests

  def test_num2name
    SUPPORTED_TYPES.each do |type|
      with_test_file("bad_name.#{type}") do |f|
        expected_file = f.parent.join("02.bad_name.#{type}")
        refute(expected_file.exist?)

        assert_output("bad_name.#{type} -> 02.bad_name.#{type}\n", '') do
          Aur::Action.new(:num2name, [f]).run!
        end

        refute(f.exist?)
        assert(expected_file.exist?)

        out, err = capture_io do
          Aur::Action.new(:num2name, [expected_file]).run!
        end

        assert_empty(err)
        assert_equal("No change required.\n", out)
      end
    end
  end

  def test_num2name_no_number_tag
    SUPPORTED_TYPES.each do |type|
      with_test_file("test_tone--100hz.#{type}") do |f|
        target = f.parent.join("06.test_tone--100hz.#{type}")

        assert f.exist?
        refute target.exist?

        assert_output("#{f.basename} -> #{target.basename}\n", '') do
          Aur::Action.new(:num2name, [f]).run!
        end

        refute f.exist?
        assert target.exist?
      end
    end
  end

  def action
    :num2name
  end
end

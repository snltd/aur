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

  def test_num2name_number_tag
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("test.number_tag.#{type}")
        target = f.parent.join("02.#{f.basename}")

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

  def test_num2name_no_number_tag
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("test.no_number_tag.#{type}")
        target = f.parent.join("00.#{f.basename}")

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

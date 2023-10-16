#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur tag2name' commands against things, and verify the results
#
class TestTag2NameCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'tag2name')

  include Aur::CommandTests

  def test_flac_tag2name
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("bad_name.#{type}")
        expected = "02.null_set.sammy_davis_jr--dancing.#{type}"

        assert_output("bad_name.#{type} -> #{expected}\n", '') do
          Aur::Action.new(action, [f]).run!
        end

        refute(f.exist?)
        assert f.parent.join(expected).exist?
      end
    end
  end

  def action = :tag2name
end

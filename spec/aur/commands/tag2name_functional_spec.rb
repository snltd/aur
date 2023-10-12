#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur tag2name' commands against things, and verify the results
#
class TestTag2NameCommand < Minitest::Test
  parallelize_me!

  include Aur::CommandTests

  def test_flac_tag2name
    SUPPORTED_TYPES.each do |type|
      expected = "02.null_set.sammy_davis_jr--dancing.#{type}"

      with_test_file("bad_name.#{type}") do |f|
        assert_output("bad_name.#{type} -> #{expected}\n", '') do
          Aur::Action.new(:tag2name, [f]).run!
        end

        refute(f.exist?)
        assert f.parent.join(expected).exist?
      end
    end
  end

  def action
    :tag2name
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur num2name' commands against things, and verify the results
#
class TestNum2NameCommand < MiniTest::Test
  include Aur::CommandTests

  def test_num2name
    SUPPORTED_TYPES.each do |type|
      with_test_file("bad_name.#{type}") do |f|
        expected_file = TMP_DIR + "02.bad_name.#{type}"
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
      setup_test_dir
      source_file = TMP_DIR + "untagged_file.#{type}"
      FileUtils.cp(RES_DIR + "01.test_artist.untagged_song.#{type}",
                   source_file)

      assert(source_file.exist?)

      assert_output(
        "untagged_file.#{type} -> 00.untagged_file.#{type}\n", ''
      ) do
        Aur::Action.new(:num2name, [source_file]).run!
      end

      refute(source_file.exist?)
      assert (TMP_DIR + "00.untagged_file.#{type}").exist?
      cleanup_test_dir
    end
  end

  def action
    :num2name
  end
end

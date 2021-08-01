#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur tag2name' commands against things, and verify the results
#
class TestTag2NameCommand < MiniTest::Test
  def test_flac_tag2name
    with_test_file('bad_name.flac') do |f|
      out, err = capture_io { Aur::Action.new(:tag2name, [f]).run! }

      assert_empty(err)
      assert_equal(
        'bad_name.flac -> 02.the_null_set.sammy_davis_jr-dancing.flac',
        out.strip
      )

      refute(f.exist?)
      assert (TMP_DIR + '02.the_null_set.sammy_davis_jr-dancing.flac').exist?
    end
  end

  def test_mp3_tag2name
    with_test_file('bad_name.mp3') do |f|
      out, err = capture_io { Aur::Action.new(:tag2name, [f]).run! }

      assert_empty(err)
      assert_equal(
        "bad_name.mp3 -> 02.the_null_set.sammy_davis_jr-dancing.mp3\n",
        out
      )

      refute(f.exist?)
      assert (TMP_DIR + '02.the_null_set.sammy_davis_jr-dancing.mp3').exist?
    end
  end
end

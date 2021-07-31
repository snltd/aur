#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/command'

# Run 'aur numname' commands against things, and verify the results
#
class TestNumberCommand < MiniTest::Test
  def test_flac_number
    with_test_file('01.the_null_set.song_one.flac') do |f|
      out, = capture_io { Aur::Command.new(:info, [f]).run! }
      refute_match(/Track no : 1/, out)

      out, err = capture_io { Aur::Command.new(:number, [f]).run! }
      assert_empty(err)
      assert_equal('t_num -> 1', out.strip)

      assert(f.exist?)

      out, err = capture_io { Aur::Command.new(:info, [f]).run! }
      assert_empty(err)
      assert_match(/Track no : 1/, out)
    end
  end

  def _test_mp3_number
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      out, = capture_io { Aur::Command.new(:info, [f]).run! }
      refute_match(/Track no : 1/, out)

      out, err = capture_io { Aur::Command.new(:number, [f]).run! }
      assert_empty(err)
      assert_equal('t_num -> 1', out.strip)

      assert(f.exist?)

      out, err = capture_io { Aur::Command.new(:info, [f]).run! }
      assert_empty(err)
      assert_match(/Track no : 1/, out)
    end
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur num2name' commands against things, and verify the results
#
class TestName2NumCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac_name2num
    with_test_file('01.the_null_set.song_one.flac') do |f|
      out, = capture_io { Aur::Action.new(:info, [f]).run! }
      refute_match(/Track no : 1/, out)

      out, err = capture_io { Aur::Action.new(:name2num, [f]).run! }
      assert_empty(err)
      assert_equal('t_num -> 1', out.strip)

      assert(f.exist?)

      out, err = capture_io { Aur::Action.new(:info, [f]).run! }
      assert_empty(err)
      assert_match(/Track no : 1/, out)
    end
  end

  def test_mp3_name2num
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      out, = capture_io { Aur::Action.new(:info, [f]).run! }
      refute_match(/Track no : 1/, out)

      out, err = capture_io { Aur::Action.new(:name2num, [f]).run! }
      assert_empty(err)
      assert_equal('t_num -> 1', out.strip)

      assert(f.exist?)

      out, err = capture_io { Aur::Action.new(:info, [f]).run! }
      assert_empty(err)
      assert_match(/Track no : 1/, out)
    end
  end

  def action
    :name2num
  end
end

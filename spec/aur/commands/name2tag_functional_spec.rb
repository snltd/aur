#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur tag2name' commands against things, and verify the results
#
class TestName2TagCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac_name2tag
    out = <<~EOOUT
      /tmp/aurtest/01.the_null_set.song_one.flac
            artist -> The Null Set
             title -> Song One
             album -> Aurtest
             t_num -> 1
    EOOUT

    with_test_file('01.the_null_set.song_one.flac') do |f|
      assert_output(out, '') { Aur::Action.new(:name2tag, [f]).run! }
      assert(f.exist?)

      out, err = capture_io { Aur::Action.new(:info, [f]).run! }
      assert_empty(err)
      assert_match('Artist : The Null Set', out)
      assert_match('Title : Song One', out)
      assert_match('Track no : 1', out)
    end
  end

  def test_mp3_name2tag
    out = <<~EOOUT
      /tmp/aurtest/01.the_null_set.song_one.mp3
            artist -> The Null Set
             title -> Song One
             album -> Aurtest
             t_num -> 1
    EOOUT

    with_test_file('01.the_null_set.song_one.mp3') do |f|
      assert_output(out, '') { Aur::Action.new(:name2tag, [f]).run! }
      assert(f.exist?)

      out, err = capture_io { Aur::Action.new(:info, [f]).run! }
      assert_empty(err)
      assert_match('Artist : The Null Set', out)
      assert_match('Title : Song One', out)
      assert_match('Track no : 1', out)
    end
  end

  def action
    :name2tag
  end
end

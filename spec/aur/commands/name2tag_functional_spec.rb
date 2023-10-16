#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur name2tag' commands against things, and verify the results
#
class TestName2TagCommand < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'name2tag')

  parallelize_me!

  include Aur::CommandTests

  def test_name2tag
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("01.test_artist.untagged_song.#{type}")
        out, err = capture_io { Aur::Action.new(action, [f]).run! }

        assert_match(/artist -> Test Artist/, out)
        assert_match(/title -> Untagged Song/, out)
        assert_match(/t_num -> 1/, out)
        assert_empty(err)
        assert(f.exist?)

        out, err = capture_io { Aur::Action.new(:info, [f]).run! }
        assert_empty(err)
        assert_match('Artist : Test Artist', out)
        assert_match('Title : Untagged Song', out)
        assert_match('Track no : 1', out)
      end
    end
  end

  def action = :name2tag
end

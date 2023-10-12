#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur tag2name' commands against things, and verify the results
#
class TestName2TagCommand < Minitest::Test
  include Aur::CommandTests

  def test_name2tag
    SUPPORTED_TYPES.each do |type|
      with_test_file("01.test_artist.untagged_song.#{type}") do |f|
        out, err = capture_io { Aur::Action.new(:name2tag, [f]).run! }

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

  def action
    :name2tag
  end
end

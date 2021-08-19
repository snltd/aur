#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur tag2name' commands against things, and verify the results
#
class TestName2TagCommand < MiniTest::Test
  include Aur::CommandTests

  def test_name2tag
    SUPPORTED_TYPES.each do |type|
      out = <<~EOOUT
        /tmp/aurtest/01.test_artist.untagged_song.#{type}
              artist -> Test Artist
               title -> Untagged Song
               album -> Aurtest
               t_num -> 1
      EOOUT

      with_test_file("01.test_artist.untagged_song.#{type}") do |f|
        assert_output(out, '') { Aur::Action.new(:name2tag, [f]).run! }
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

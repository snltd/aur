#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur num2name' commands against things, and verify the results
#
class TestName2NumCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'name2num')

  include Aur::CommandTests

  def test_flac_name2num
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("01.test_artist.untagged_song.#{type}")
        out, err = capture_io { Aur::Action.new(:info, [f]).run! }
        refute_match(/Track no : 1/, out)
        assert_empty(err)

        assert_output("       t_num -> 1\n", '') do
          Aur::Action.new(:name2num, [f]).run!
        end

        assert(f.exist?)
        assert_output(/Track no : 1/, '') { Aur::Action.new(:info, [f]).run! }
      end
    end
  end

  def action = :name2num
end

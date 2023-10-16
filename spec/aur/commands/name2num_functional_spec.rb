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

  def test_renumber_from_filename
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("01.test_artist.untagged_song.#{type}")

        assert_nil Aur::FileInfo.new(f).our_tags[:t_num]

        assert_output("       t_num -> 1\n", '') do
          Aur::Action.new(action, [f]).run!
        end

        assert_equal('1', Aur::FileInfo.new(f).our_tags[:t_num])
      end
    end
  end

  def test_no_number_in_filename
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("bad_name.#{type}")
        assert f.exist?

        assert_output('', "No number found at start of filename\n") do
          Aur::Action.new(action, [f]).run!
        end

        assert f.exist?
      end
    end
  end

  def action = :name2num
end

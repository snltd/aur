#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur renumber' commands against things, and verify the results
#
class TestRenumberCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'renumber')

  include Aur::CommandTests

  def test_renumber_up
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("test.#{type}")
        assert_tag(f, :t_num, '6')
        outfile = "09.test.#{type}"

        assert_output("       t_num -> 9\ntest.#{type} -> #{outfile}\n", '') do
          renumber_command(f, :up, '3')
        end

        assert_tag(f.dirname.join(outfile), :t_num, '9')
      end
    end
  end

  def test_flac_renumber_down
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("test.#{type}")
        assert_tag(f, :t_num, '6')
        outfile = "02.test.#{type}"

        assert_output("       t_num -> 2\ntest.#{type} -> #{outfile}\n", '') do
          renumber_command(f, :down, '4')
        end

        assert_tag(f.dirname.join(outfile), :t_num, '2')
      end
    end
  end

  def test_flac_renumber_down_too_far
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("test.#{type}")
        assert_tag(f, :t_num, '6')

        assert_output('', "ERROR: #{f}: '-9' is an invalid t_num\n") do
          assert_raises(SystemExit) { renumber_command(f, :down, '15') }
        end

        assert_tag(f, :t_num, '6')
        assert f.exist?
      end
    end
  end

  def action = :renumber

  private

  def renumber_command(file, direction, number)
    opts = { '<file>': file, '<number>': number }

    opts[:up] = true if direction == :up
    opts[:down] = true if direction == :down

    Aur::Action.new(:renumber, [file], opts).run!
  end
end

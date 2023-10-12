#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur renumber' commands against things, and verify the results
#
class TestRenumberCommand < Minitest::Test
  include Aur::CommandTests

  def test_renumber_up
    SUPPORTED_TYPES.each do |type|
      with_test_file("test_tone--100hz.#{type}") do |f|
        assert_tag(f, :t_num, '6')
        outfile = "09.test_tone--100hz.#{type}"

        assert_output(
          "       t_num -> 9\ntest_tone--100hz.#{type} -> #{outfile}\n",
          ''
        ) do
          renumber_command(f, :up, '3')
        end

        assert_tag(f.dirname.join(outfile), :t_num, '9')
      end
    end
  end

  def test_flac_renumber_down
    SUPPORTED_TYPES.each do |type|
      with_test_file("test_tone--100hz.#{type}") do |f|
        assert_tag(f, :t_num, '6')
        outfile = "02.test_tone--100hz.#{type}"

        assert_output(
          "       t_num -> 2\ntest_tone--100hz.#{type} -> #{outfile}\n",
          ''
        ) do
          renumber_command(f, :down, '4')
        end

        assert_tag(f.dirname.join(outfile), :t_num, '2')
      end
    end
  end

  def test_flac_renumber_down_too_far
    SUPPORTED_TYPES.each do |type|
      with_test_file("test_tone--100hz.#{type}") do |f|
        assert_tag(f, :t_num, '6')

        assert_output('',
                      "ERROR: #{f}: '-9' is an invalid t_num\n") do
          assert_raises(SystemExit) { renumber_command(f, :down, '15') }
        end

        assert_tag(f, :t_num, '6')
        assert f.exist?
      end
    end
  end

  def action
    :renumber
  end
end

def renumber_command(file, direction, number)
  opts = { '<file>': file, '<number>': number }

  opts[:up] = true if direction == :up
  opts[:down] = true if direction == :down

  Aur::Action.new(:renumber, [file], opts).run!
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur renumber' commands against things, and verify the results
#
class TestRenumberCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac_renumber_up
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')
      outfile = '09.test_tone-100hz.flac'

      assert_output("       t_num -> 9\ntest_tone-100hz.flac -> #{outfile}\n",
                    '') do
        renumber_command(f, :up, '3')
      end

      assert_tag(TMP_DIR + outfile, :t_num, '9')
    end
  end

  def test_flac_renumber_down
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')
      outfile = '02.test_tone-100hz.flac'

      assert_output("       t_num -> 2\ntest_tone-100hz.flac -> #{outfile}\n",
                    '') do
        renumber_command(f, :down, '4')
      end

      assert_tag(TMP_DIR + outfile, :t_num, '2')
    end
  end

  def test_flac_renumber_down_too_far
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')

      assert_output('', "'-9' is an invalid value.\n") do
        renumber_command(f, :down, '15')
      end

      assert_tag(f, :t_num, '06')
      assert f.exist?
    end
  end

  def test_mp3_renumber_up
    with_test_file('test_tone-100hz.mp3') do |f|
      assert_tag(f, :t_num, '6')

      outfile = '09.test_tone-100hz.mp3'

      assert_output("       t_num -> 9\ntest_tone-100hz.mp3 -> #{outfile}\n",
                    '') do
        renumber_command(f, :up, '3')
      end

      assert_tag(TMP_DIR + outfile, :t_num, '9')
    end
  end

  def test_mp3_renumber_down
    with_test_file('test_tone-100hz.mp3') do |f|
      assert_tag(f, :t_num, '6')

      outfile = '02.test_tone-100hz.mp3'

      assert_output("       t_num -> 2\ntest_tone-100hz.mp3 -> #{outfile}\n",
                    '') do
        renumber_command(f, :down, '4')
      end

      assert_tag(TMP_DIR + outfile, :t_num, '2')
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

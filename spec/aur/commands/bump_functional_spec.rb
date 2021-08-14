#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur bump' commands against things, and verify the results
#
class TestBumpCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac_bump_up
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')
      outfile = '09.test_tone-100hz.flac'

      assert_output("       t_num -> 9\ntest_tone-100hz.flac -> #{outfile}\n",
                    '') do
        bump_command(f, '3')
      end

      assert_tag(TMP_DIR + outfile, :t_num, '9')
    end
  end

  def test_flac_bump_down
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')
      outfile = '02.test_tone-100hz.flac'

      assert_output("       t_num -> 2\ntest_tone-100hz.flac -> #{outfile}\n",
                    '') do
        bump_command(f, '-4')
      end

      assert_tag(TMP_DIR + outfile, :t_num, '2')
    end
  end

  def test_flac_bump_down_too_far
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')

      assert_output('', "'-9' is an invalid value.\n") do
        bump_command(f, '-15')
      end

      assert_tag(f, :t_num, '06')
      assert f.exist?
    end
  end

  def test_mp3_bump_up
    with_test_file('test_tone-100hz.mp3') do |f|
      assert_tag(f, :t_num, '6')

      outfile = '09.test_tone-100hz.mp3'

      assert_output("       t_num -> 9\ntest_tone-100hz.mp3 -> #{outfile}\n",
                    '') do
        bump_command(f, '3')
      end

      assert_tag(TMP_DIR + outfile, :t_num, '9')
    end
  end

  def test_mp3_bump_down
    with_test_file('test_tone-100hz.mp3') do |f|
      assert_tag(f, :t_num, '6')

      outfile = '02.test_tone-100hz.mp3'

      assert_output("       t_num -> 2\ntest_tone-100hz.mp3 -> #{outfile}\n",
                    '') do
        bump_command(f, '-4')
      end

      assert_tag(TMP_DIR + outfile, :t_num, '2')
    end
  end

  def action
    :bump
  end
end

def bump_command(file, number)
  opts = { '<file>': file, '<number>': number }

  Aur::Action.new(:bump, [file], opts).run!
end

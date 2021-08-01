#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur bump' commands against things, and verify the results
#
class TestBumpCommand < MiniTest::Test
  def test_flac_bump_up
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')

      out, err = capture_io { bump_command(f, '3') }
      assert_empty(err)
      out = out.split("\n")
      assert_equal('       t_num -> 9', out.first)
      assert_equal('test_tone-100hz.flac -> 09.test_tone-100hz.flac', out.last)

      assert_tag(TMP_DIR + '09.test_tone-100hz.flac', :t_num, '9')
    end
  end

  def test_flac_bump_down
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')

      out, err = capture_io { bump_command(f, '-4') }
      assert_empty(err)
      out = out.split("\n")
      assert_equal('       t_num -> 2', out.first)
      assert_equal('test_tone-100hz.flac -> 02.test_tone-100hz.flac', out.last)

      assert_tag(TMP_DIR + '02.test_tone-100hz.flac', :t_num, '2')
    end
  end

  def test_flac_bump_down_too_far
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :t_num, '06')

      out, err = capture_io { bump_command(f, '-15') }
      assert_empty(out)
      assert_equal("'-9' is an invalid value.\n", err)
      assert_tag(f, :t_num, '06')
      assert f.exist?
    end
  end

  def test_mp3_bump_up
    with_test_file('test_tone-100hz.mp3') do |f|
      assert_tag(f, :t_num, 6)

      out, err = capture_io { bump_command(f, '3') }
      assert_empty(err)
      out = out.split("\n")
      assert_equal('       t_num -> 9', out.first)
      assert_equal('test_tone-100hz.mp3 -> 09.test_tone-100hz.mp3', out.last)

      assert_tag(TMP_DIR + '09.test_tone-100hz.mp3', :t_num, 9)
    end
  end

  def test_mp3_bump_down
    with_test_file('test_tone-100hz.mp3') do |f|
      assert_tag(f, :t_num, 6)

      out, err = capture_io { bump_command(f, '-4') }
      assert_empty(err)
      out = out.split("\n")
      assert_equal('       t_num -> 2', out.first)
      assert_equal('test_tone-100hz.mp3 -> 02.test_tone-100hz.mp3', out.last)

      assert_tag(TMP_DIR + '02.test_tone-100hz.mp3', :t_num, 2)
    end
  end
end

def bump_command(file, number)
  opts = { '<file>': file, '<number>': number }

  Aur::Action.new(:bump, [file], opts).run!
end

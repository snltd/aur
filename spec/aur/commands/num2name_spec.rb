#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/num2name'

# Tests for num2name command
#
class TestNum2name < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'num2name')

  def setup
    @flac = Aur::Command::Num2name.new(T_DIR.join('test.flac'))
    @mp3 = Aur::Command::Num2name.new(T_DIR.join('test.mp3'))
  end

  def test_new_filename_flac
    assert_equal('06.test.flac', @flac.new_filename)
  end

  def test_new_filename_mp3
    assert_equal('06.test.mp3', @mp3.new_filename)
  end

  def test_new_filename_flac_missing_data
    assert_equal('00.test.flac',
                 @flac.new_filename(TestTags.new({ title: 'Another Song' })))
  end

  def test_new_filename_mp3_all_data
    assert_equal('10.test.mp3',
                 @mp3.new_filename(
                   TestTags.new({ artist: 'Band', title: 'Song', t_num: '10' })
                 ))
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/base'

# Tests for command base class
#
class TestBase < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'base')

  def test_initialize_flac
    obj = Aur::Command::Base.new(T_DIR.join('test.flac'))
    assert_equal(T_DIR.join('test.flac'), obj.file)
    assert_instance_of(Aur::FileInfo, obj.info)
  end

  def test_initialize_mp3
    obj = Aur::Command::Base.new(T_DIR.join('test.mp3'))
    assert_equal(T_DIR.join('test.mp3'), obj.file)
    assert_instance_of(Aur::FileInfo, obj.info)
  end

  def test_initialize_jpg
    assert_raises(NameError) { Aur::Base.new(T_DIR.join('front.jpg')) }
  end
end

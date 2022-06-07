#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/base'

# Tests for command base class
#
class TestBase < MiniTest::Test
  def test_initialize_flac
    obj = Aur::Command::Base.new(RES_DIR.join('test_tone-100hz.flac'))
    assert_equal(RES_DIR.join('test_tone-100hz.flac'), obj.file)
    assert_instance_of(Aur::FileInfo, obj.info)
  end

  def test_initialize_mp3
    obj = Aur::Command::Base.new(RES_DIR.join('test_tone-100hz.mp3'))
    assert_equal(RES_DIR.join('test_tone-100hz.mp3'), obj.file)
    assert_instance_of(Aur::FileInfo, obj.info)
  end

  def test_initialize_png
    assert_raises(NameError) { Aur::Base.new(RES_DIR.join('front.png')) }
  end
end

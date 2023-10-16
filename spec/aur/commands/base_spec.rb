#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/base'

# Tests for command base class
#
class TestBase < Minitest::Test
  parallelize_me!

  def test_initialize_flac
    obj = Aur::Command::Base.new(UNIT_FLAC)
    assert_equal(UNIT_FLAC, obj.file)
    assert_instance_of(Aur::FileInfo, obj.info)
  end

  def test_initialize_mp3
    obj = Aur::Command::Base.new(UNIT_MP3)
    assert_equal(UNIT_MP3, obj.file)
    assert_instance_of(Aur::FileInfo, obj.info)
  end

  def test_initialize_jpg
    assert_raises(NameError) { Aur::Base.new(UNIT_JPG) }
  end
end

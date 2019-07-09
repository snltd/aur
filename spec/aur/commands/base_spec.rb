#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/base'

# Tests for command base class
#
class TestBase < MiniTest::Test
  def test_initialize_flac
    obj = Aur::Base.new(FLAC_TEST)
    assert_equal(FLAC_TEST, obj.file)
    assert_instance_of(Aur::FileInfo::Flac, obj.info)
  end

  def test_initialize_mp3
    obj = Aur::Base.new(MP3_TEST)
    assert_equal(MP3_TEST, obj.file)
    assert_instance_of(Aur::FileInfo::Mp3, obj.info)
  end

  def test_initialize_png
    assert_raises(NameError) { Aur::Base.new(RES_DIR + 'front.png') }
  end
end

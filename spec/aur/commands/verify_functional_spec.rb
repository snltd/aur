#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/command'
require_relative '../../../lib/aur/constants'

# Run 'aur verify' commands against things, and verify the output
#
class TestVerifyCmd < MiniTest::Test
  attr_reader :dir

  def test_verify_nothing
    out, err = capture_io do
      Aur::Command.new(:verify, [RES_DIR + 'front.png']).run!
    end

    assert_equal("No valid files supplied.\n", err)
    assert_empty(out)
  end

  def test_flac_verify
    skip unless BIN[:flac].exist?

    out, err = capture_io do
      Aur::Command.new(:verify, [RES_DIR + 'bad_name.flac']).run!
    end

    assert_match(/^bad_name.flac\s+OK$/, out)
    assert_empty(err)
  end

  def test_mp3_verify
    out, err = capture_io do
      Aur::Command.new(:verify, [RES_DIR + 'bad_name.mp3']).run!
    end

    assert_empty(out)
    assert_equal("MP3 files cannot be verified.\n", err)
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/commands/namecheck'

# Test namecheck against a real filesystem
#
class TestNamecheckCmd < MiniTest::Test
  THES_DIR = RES_DIR.join('namecheck', 'flac', 'thes')
  SIMILAR_DIR = RES_DIR.join('namecheck', 'mp3', 'similar')

  def test_thes
    out, = capture_io { act(THES_DIR) }
    lines = out.split("\n")
    assert_equal('The Artist', lines[0])
    assert lines[1].end_with?('namecheck/flac/thes/albums/abc/artist.album')
    assert_equal('Artist', lines[2])
    assert lines[3].end_with?('namecheck/flac/thes/tracks')
  end

  def test_no_thes
    assert_silent { act(SIMILAR_DIR) }
  end

  private

  def act(*dirs)
    Aur::Action.new(:namecheck, [], { '<directory>': dirs }).run!
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/commands/namecheck'

# Test namecheck against a real filesystem
#
class TestNamecheckCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'namecheck')

  def test_thes
    out, err = capture_io { act(T_DIR.join('flac', 'thes')) }
    assert_empty(err)
    lines = out.split("\n")
    assert_equal(4, lines.size)
    assert_equal('The Artist', lines[0])
    assert lines[1].end_with?('namecheck/flac/thes/albums/abc/artist.album')
    assert_equal('Artist', lines[2])
    assert lines[3].end_with?('namecheck/flac/thes/tracks')
  end

  def test_similars
    out, err = capture_io { act(T_DIR.join('mp3', 'similar')) }
    assert_empty(err)
    lines = out.split("\n")
    assert_equal(10, lines.size)
    assert_equal('The B52s', lines[0])
    assert lines[1].end_with?('namecheck/mp3/similar/tracks')
    assert_equal("The B-52's", lines[2])
    assert lines[3].end_with?('namecheck/mp3/similar/albums/b-52s.wild_planet')
  end

  private

  def act(*dirs)
    Aur::Action.new(:namecheck, [], { '<directory>': dirs }).run!
  end
end

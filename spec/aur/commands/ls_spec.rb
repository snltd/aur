#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/ls'

# Tests the internals of the 'aur ls' command
#
class TestLs < Minitest::Test
  def test_format_line_short
    t = Aur::Command::Ls.new

    [70, 80, 90, 100, 120, 150, 180].each do |n|
      assert_equal(n, t.format_line(t.format_string(n), short_tags).length)
    end
  end

  private

  def short_tags
    TestTags.new({ artist: 'Slint', album: 'Tweez', title: 'Ron', t_num: 1 })
  end

  def long_tags
    TestTags.new(
      {
        artist: 'of Montreal',
        title: 'I Felt Like Smashing My Face Through a Clear Glass Window',
        album: "The Bird who Continues to Eat the Rabbit's Flower",
        t_num: 8
      }
    )
  end
end

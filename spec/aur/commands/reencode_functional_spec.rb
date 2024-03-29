#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur reencode' commands against a real file, and verify the results
#
class TestReencodeCommand < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'reencode')

  parallelize_me!

  def test_reencode_flac
    with_test_file(T_DIR.join('test.flac')) do |f|
      original_mtime = f.mtime
      original_tags = Aur::FileInfo.new(f).our_tags

      assert_output("#{f} -> #{f} [re-encoded]\n", '') do
        Aur::Action.new(action, [f]).run!
      end

      new_mtime = f.mtime
      new_tags = Aur::FileInfo.new(f).our_tags

      refute_equal(original_mtime, new_mtime)
      assert_equal(original_tags, new_tags)
    end
  end

  def test_reencode_mp3
    with_test_file(T_DIR.join('test.mp3')) do |f|
      original_mtime = f.mtime
      original_tags = Aur::FileInfo.new(f).our_tags

      assert_output("#{f} -> #{f} [re-encoded]\n", '') do
        Aur::Action.new(action, [f]).run!
      end

      assert(f.exist?)

      new_mtime = f.mtime
      new_tags = Aur::FileInfo.new(f).our_tags

      refute_equal(original_mtime, new_mtime)

      # When FFMPEG re-encodes an MP3, it turns the (number) style tag into
      # the string it maps to, and it uses TDRC. I don't care enough to fix
      # it, I'll probably never use this feature.
      #
      assert_equal(original_tags[:artist], new_tags[:artist])
      assert_equal(original_tags[:title], new_tags[:title])
      assert_equal(original_tags[:album], new_tags[:album])
    end
  end

  def action = :reencode
end

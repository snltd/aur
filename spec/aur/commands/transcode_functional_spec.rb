#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur transcode' commands against a real file, and verify the results
#
class TestTranscodeCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'transcode')

  def test_transcode_flac_to_wav_and_back
    with_test_file(T_DIR.join('test.flac')) do |f|
      wav = f.parent.join('test.wav')
      original_tags = Aur::FileInfo.new(f).our_tags

      assert_output("#{f} -> #{wav}\n", '') do
        Aur::Action.new(:transcode, [f], '<newtype>': 'wav').run!
      end

      assert(f.exist?)
      assert(wav.exist?)

      f.unlink
      refute(f.exist?)

      assert_output("#{wav} -> #{f}\n", '') do
        Aur::Action.new(:transcode, [wav], '<newtype>': 'flac').run!
      end

      assert(f.exist?)
      assert(wav.exist?)

      new_tags = Aur::FileInfo.new(f).our_tags

      assert_equal(original_tags, new_tags)
    end
  end

  def test_transcode_bad_flac
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("not_really_a.#{type}")
        assert_output("#{f} -> #{f.parent.join('not_really_a.wav')}\n",
                      "ERROR: cannot process '#{f}'.\n") do
          Aur::Action.new(:transcode, [f], '<newtype>': 'wav').run!
        end
      end
    end
  end
end

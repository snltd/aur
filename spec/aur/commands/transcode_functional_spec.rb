#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur reencode' commands against a real file, and verify the results
#
class TestReencodeCommand < MiniTest::Test
  def test_transcode_flac_to_wav_and_back
    with_test_file('test_tone-100hz.flac') do |f|
      skip unless BIN[:ffmpeg].exist?

      wav = TMP_DIR + 'test_tone-100hz.wav'
      original_tags = Aur::FileInfo::Flac.new(f).our_tags

      out, err = capture_io do
        Aur::Action.new(:transcode, [f], '<newtype>': 'wav').run!
      end

      assert_equal("#{f} -> #{wav}\n", out)
      assert_empty(err)
      assert(f.exist?)
      assert(wav.exist?)

      f.unlink
      refute(f.exist?)

      out, err = capture_io do
        Aur::Action.new(:transcode, [wav], '<newtype>': 'flac').run!
      end

      assert_equal("#{wav} -> #{f}\n", out)
      assert_empty(err)
      assert(f.exist?)
      assert(wav.exist?)

      new_tags = Aur::FileInfo::Flac.new(f).our_tags

      assert_equal(original_tags, new_tags)
    end
  end
end

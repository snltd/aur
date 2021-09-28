#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur reencode' commands against a real file, and verify the results
#
class TestReencodeCommand < MiniTest::Test
  def test_transcode_flac_to_wav_and_back
    skip unless BIN[:ffmpeg].exist?

    with_test_file('test_tone-100hz.flac') do |f|
      wav = TMP_DIR + 'test_tone-100hz.wav'
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
    skip unless BIN[:ffmpeg].exist?

    SUPPORTED_TYPES.each do |type|
      with_test_file(RES_DIR + "not_really_a.#{type}") do |f|
        assert_output("#{f} -> #{TMP_DIR}/not_really_a.wav\n",
                      "ERROR: cannot process '#{f}'.\n") do
          assert_raises(SystemExit) do
            Aur::Action.new(:transcode, [f], '<newtype>': 'wav').run!
          end
        end
      end
    end
  end
end

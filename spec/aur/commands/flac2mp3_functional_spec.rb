#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur flac2mp3' commands against things, and verify the results
#
class TestFlac2Mp3Command < MiniTest::Test
  def test_flac2mp3
    skip unless BIN[:flac].exist?
    skip unless BIN[:lame].exist?

    with_test_file('test_tone-100hz.flac') do |f|
      expected_file = TMP_DIR + 'test_tone-100hz.mp3'
      refute(expected_file.exist?)

      out, err = capture_io { Aur::Action.new(:flac2mp3, [f]).run! }

      assert_equal("#{f} -> #{TMP_DIR}/test_tone-100hz.mp3\n", out)
      assert_empty(err)

      assert(f.exist?)
      assert(expected_file.exist?)

      assert_tag(expected_file, :title, '100hz')
      assert_tag(expected_file, :artist, 'Test Tones')
      assert_tag(expected_file, :album, 'Test Tones')
      assert_tag(expected_file, :t_num, 6)
    end
  end

  def test_flac2mp3_mp3
    with_test_file('test_tone-100hz.mp3') do |f|
      assert_raises(Aur::Exception::UnsupportedFiletype) do
        Aur::Action.new(:flac2mp3, [f]).run!
      end
    end
  end
end

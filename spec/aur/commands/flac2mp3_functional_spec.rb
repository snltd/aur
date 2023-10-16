#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur flac2mp3' commands against things, and verify the results
#
class TestFlac2Mp3Command < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'flac2mp3')

  include Aur::CommandTests

  def test_flac2mp3
    with_test_file(T_DIR.join('test.flac')) do |f|
      expected_file = f.parent.join('test.mp3')
      refute expected_file.exist?

      assert_output("#{f} -> #{expected_file}\n", '') do
        Aur::Action.new(action, [f]).run!
      end

      assert(f.exist?)
      assert(expected_file.exist?)
      assert_tag(expected_file, :title, '100hz')
      assert_tag(expected_file, :artist, 'Test Tones')
      assert_tag(expected_file, :album, 'Test Tones')
      assert_tag(expected_file, :t_num, 6)
    end
  end

  def test_flac2mp3_mp3
    with_test_file(T_DIR.join('test.mp3')) do |f|
      assert_output(
        nil,
        "ERROR: Unhandled error on #{f.parent.join('test.mp3')}\n"
      ) do
        assert_raises(SystemExit) { Aur::Action.new(action, [f]).run! }
      end
    end
  end

  def action = :flac2mp3
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/command'

# Run 'aur numname' commands against things, and verify the results
#
class TestNumberCommand < MiniTest::Test
  def test_flac_inumber
    setup_test_dir
    source_file = TMP_DIR + '01.the_null_set.song_one.flac'
    FileUtils.cp(RES_DIR + '01.the_null_set.song_one.flac', TMP_DIR)
    assert(source_file.exist?)

    out, = capture_io { Aur::Command.new(:info, [source_file]).run! }
    refute_match(/Track no : 2/, out)

    with_stdin do |input|
      input.puts "2\n"
      out, err = capture_io { Aur::Command.new(:inumber, [source_file]).run! }
      assert_empty(err)
      assert_equal(
        '01.the_null_set.song_one.flac > ' \
        "01.the_null_set.song_one.flac -> 02.the_null_set.song_one.flac\n", out
      )
    end

    refute(source_file.exist?)
    new_file = TMP_DIR + '02.the_null_set.song_one.flac'
    assert new_file.exist?

    out, err = capture_io { Aur::Command.new(:info, [new_file]).run! }
    assert_empty(err)
    assert_match(/Track no : 2/, out)

    cleanup_test_dir
  end

  def _test_mp3_inumber
    setup_test_dir
    source_file = TMP_DIR + 'bad_name.mp3'
    FileUtils.cp(RES_DIR + 'bad_name.mp3', TMP_DIR)
    assert(source_file.exist?)

    out, = capture_io { Aur::Command.new(:info, [source_file]).run! }
    refute_match(/Track no : 12/, out)

    with_stdin do |input|
      input.puts "12\n"
      out, err = capture_io { Aur::Command.new(:inumber, [source_file]).run! }
      assert_empty(err)
      assert_equal("bad_name.mp3 > bad_name.mp3 -> 12.bad_name.mp3\n", out)
    end

    refute(source_file.exist?)
    new_file = TMP_DIR + '12.bad_name.mp3'
    assert new_file.exist?

    out, err = capture_io { Aur::Command.new(:info, [new_file]).run! }
    assert_empty(err)
    assert_match(/Track no : 12/, out)

    cleanup_test_dir
  end
end

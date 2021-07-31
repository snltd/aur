#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/command'

# Run 'aur numname' commands against things, and verify the results
#
class TestNumberCommand < MiniTest::Test
  def test_flac_number
    setup_test_dir
    source_file = TMP_DIR + '01.the_null_set.song_one.flac'
    FileUtils.cp(RES_DIR + '01.the_null_set.song_one.flac', TMP_DIR)
    assert(source_file.exist?)

    out, = capture_io { Aur::Command.new(:info, [source_file]).run! }
    refute_match(/Track no : 2/, out)

    out, err = capture_io { Aur::Command.new(:number, [source_file]).run! }
    assert_empty(err)
    assert_equal('t_num -> 1', out.strip)

    assert(source_file.exist?)

    out, err = capture_io { Aur::Command.new(:info, [source_file]).run! }
    assert_empty(err)
    assert_match(/Track no : 2/, out)

    cleanup_test_dir
  end

  def test_mp3_number
    setup_test_dir
    source_file = TMP_DIR + '01.the_null_set.song_one.mp3'
    FileUtils.cp(RES_DIR + '01.the_null_set.song_one.mp3', TMP_DIR)
    assert(source_file.exist?)

    out, = capture_io { Aur::Command.new(:info, [source_file]).run! }
    refute_match(/Track no : 2/, out)

    out, err = capture_io { Aur::Command.new(:number, [source_file]).run! }
    assert_empty(err)
    assert_equal('t_num -> 1', out.strip)

    assert(source_file.exist?)

    out, err = capture_io { Aur::Command.new(:info, [source_file]).run! }
    assert_empty(err)
    assert_match(/Track no : 2/, out)

    cleanup_test_dir
  end
end

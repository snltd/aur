#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/command'

# Run 'aur numname' commands against things, and verify the results
#
class TestNumNameCommand < MiniTest::Test
  def _test_flac_numname
    setup_test_dir
    source_file = TMP_DIR + 'bad_name.flac'
    FileUtils.cp(RES_DIR + 'bad_name.flac', TMP_DIR)
    assert(source_file.exist?)

    out, err = capture_io { Aur::Command.new(:numname, [source_file]).run! }
    assert_empty(err)
    assert_equal('bad_name.flac -> 02.bad_name.flac', out.strip)

    refute(source_file.exist?)
    assert (TMP_DIR + '02.bad_name.flac').exist?

    out, err = capture_io do
      Aur::Command.new(:numname, [TMP_DIR + '02.bad_name.flac']).run!
    end

    assert_empty(err)
    assert_equal("No change required.\n", out)

    cleanup_test_dir
  end

  def test_flac_numname_no_number_tag
    setup_test_dir
    source_file = TMP_DIR + 'untagged_file.flac'
    FileUtils.cp(RES_DIR + '01.the_null_set.song_one.flac', source_file)

    assert(source_file.exist?)

    out, err = capture_io { Aur::Command.new(:numname, [source_file]).run! }
    assert_equal("untagged_file.flac -> 00.untagged_file.flac\n", out)
    assert_empty(err)
    refute(source_file.exist?)
    assert (TMP_DIR + '00.untagged_file.flac').exist?
    cleanup_test_dir
  end

  def _test_mp3_numname
    setup_test_dir
    source_file = TMP_DIR + 'bad_name.mp3'
    FileUtils.cp(RES_DIR + 'bad_name.mp3', TMP_DIR)

    assert(source_file.exist?)

    out, err = capture_io { Aur::Command.new(:numname, [source_file]).run! }

    assert_empty(err)
    assert_equal('bad_name.mp3 -> 02.bad_name.mp3', out.strip)

    refute(source_file.exist?)
    assert (TMP_DIR + '02.bad_name.mp3').exist?

    out, err = capture_io do
      Aur::Command.new(:numname, [TMP_DIR + '02.bad_name.mp3']).run!
    end

    assert_empty(err)
    assert_equal("No change required.\n", out)

    cleanup_test_dir
  end
end

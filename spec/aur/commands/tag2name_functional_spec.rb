#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/command'

# Run 'aur tag2name' commands against things, and verify the results
#
class TestTag2NameCommand < MiniTest::Test
  def test_flac_tag2name
    setup_test_dir
    source_file = TMP_DIR + 'bad_name.flac'
    FileUtils.cp(RES_DIR + 'bad_name.flac', TMP_DIR)

    assert(source_file.exist?)

    out, err = capture_io do
      Aur::Command.new(:tag2name, [TMP_DIR + 'bad_name.flac']).run!
    end

    assert_empty(err)
    assert_equal(
      'bad_name.flac -> 02.the_null_set.sammy_davis_jr-dancing.flac',
      out.strip
    )

    refute(source_file.exist?)
    assert (TMP_DIR + '02.the_null_set.sammy_davis_jr-dancing.flac').exist?
    cleanup_test_dir
  end

  def test_mp3_tag2name
    setup_test_dir
    source_file = TMP_DIR + 'bad_name.mp3'
    FileUtils.cp(RES_DIR + 'bad_name.mp3', TMP_DIR)

    assert(source_file.exist?)

    out, err = capture_io do
      Aur::Command.new(:tag2name, [TMP_DIR + 'bad_name.mp3']).run!
    end

    assert_empty(err)
    assert_equal('bad_name.mp3 -> 02.the_null_set.sammy_davis_jr-dancing.mp3',
                 out.strip)

    refute(source_file.exist?)
    assert (TMP_DIR + '02.the_null_set.sammy_davis_jr-dancing.mp3').exist?
    cleanup_test_dir
  end
end

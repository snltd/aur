#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/command'

# Run 'aur tag2name' commands against things, and verify the results
#
class TestName2TagCommand < MiniTest::Test
  attr_reader :dir

  def setup_test_dir
    @dir = Pathname.new('/tmp/aurtest')
    FileUtils.rm_r(dir) if dir.exist?
    FileUtils.mkdir_p(dir)
  end

  def cleanup_test_dir
    @dir = Pathname.new('/tmp/aurtest')
    FileUtils.rm_r(dir) if dir.exist?
  end

  def test_flac_name2tag
    setup_test_dir
    source_file = @dir + '01.the_null_set.heavy_rhythm_machine.flac'
    FileUtils.cp(FRES_DIR + '01.the_null_set.heavy_rhythm_machine.flac',
                 TMP_DIR)

    assert(source_file.exist?)

    out, err = capture_io { Aur::Command.new(:name2tag, [source_file]).run! }

    assert_empty(err)
    assert_equal(out, flac_name2tag_output)
    assert(source_file.exist?)

    out, err = capture_io { Aur::Command.new(:info, [source_file]).run! }
    assert_empty(err)
    assert_match('Artist : The Null Set', out)
    assert_match('Title : Heavy Rhythm Machine', out)
    assert_match('Track no : 01', out)

    cleanup_test_dir
  end

  def test_mp3_name2tag
    setup_test_dir
    source_file = TMP_DIR + '01.the_null_set.heavy_rhythm_machine.mp3'
    FileUtils.cp(FRES_DIR + '01.the_null_set.heavy_rhythm_machine.mp3', TMP_DIR)

    assert(source_file.exist?)

    out, err = capture_io { Aur::Command.new(:name2tag, [source_file]).run! }

    assert_empty(err)
    assert_equal(out, mp3_name2tag_output)
    assert(source_file.exist?)
    cleanup_test_dir
  end
end

def flac_name2tag_output
  %(/tmp/aurtest/01.the_null_set.heavy_rhythm_machine.flac
      artist -> The Null Set
       title -> Heavy Rhythm Machine
       album -> Aurtest
 tracknumber -> 01
)
end

def mp3_name2tag_output
  %(/tmp/aurtest/01.the_null_set.heavy_rhythm_machine.mp3
      artist -> The Null Set
       title -> Heavy Rhythm Machine
       album -> Aurtest
    tracknum -> 01
)
end

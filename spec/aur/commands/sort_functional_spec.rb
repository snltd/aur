#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/command'

# Run 'aur sort' commands against things, and verify the results
#
class TestNumNameCommand < MiniTest::Test
  def test_flac_numname
    setup_test_dir

    test_files = RES_DIR.children

    test_files.each { |f| FileUtils.cp(RES_DIR + f, TMP_DIR) }

    assert(test_files.all? { |f| (TMP_DIR + f.basename).exist? })

    out, err = capture_io { Aur::Command.new(:sort, TMP_DIR.children).run! }

    assert_empty(err)
    assert_equal(out.split("\n").sort, expected_output_lines.sort)

    new_dirs = %w[test_tones.test_tones the_null_set.some_stuff_by
                  unknown_artist.unknown_album]

    assert(new_dirs.all? { |d| (TMP_DIR + d).exist? })
    assert(new_dirs.all? { |d| (TMP_DIR + d).directory? })

    refute(test_files.all? { |f| (TMP_DIR + f.basename).exist? })

    files = %w[the_null_set.some_stuff_by/bad_name.flac
               the_null_set.some_stuff_by/bad_name.mp3
               test_tones.test_tones/test_tone-100hz.flac
               test_tones.test_tones/test_tone-100hz.mp3
               unknown_artist.unknown_album/01.the_null_set.song_one.mp3
               unknown_artist.unknown_album/01.the_null_set.song_one.flac]

    assert(files.all? { |f| (TMP_DIR + f).exist? })
    cleanup_test_dir
  end
end

def expected_output_lines
  ['01.the_null_set.song_one.flac -> unknown_artist.unknown_album/',
   '01.the_null_set.song_one.mp3 -> unknown_artist.unknown_album/',
   'bad_name.mp3 -> the_null_set.some_stuff_by/',
   'bad_name.flac -> the_null_set.some_stuff_by/',
   'test_tone-100hz.mp3 -> test_tones.test_tones/',
   'test_tone-100hz.flac -> test_tones.test_tones/']
end

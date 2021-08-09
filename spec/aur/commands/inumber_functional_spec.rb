#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur numname' commands against things, and verify the results
#
class TestNumberCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac_inumber
    with_test_file('01.the_null_set.song_one.flac') do |f|
      out, = capture_io { Aur::Action.new(:info, [f]).run! }
      refute_match(/Track no : 4/, out)

      with_stdin do |input|
        input.puts "4\n"
        out, err = capture_io { Aur::Action.new(:inumber, [f]).run! }
        assert_empty(err)
        assert_equal(
          '01.the_null_set.song_one.flac > ' \
          "       t_num -> 4\n" \
          "01.the_null_set.song_one.flac -> 04.the_null_set.song_one.flac\n",
          out
        )
      end

      refute(f.exist?)
      new_file = TMP_DIR + '04.the_null_set.song_one.flac'
      assert new_file.exist?

      out, err = capture_io { Aur::Action.new(:info, [new_file]).run! }
      assert_empty(err)
      assert_match(/Track no : 4$/, out)
    end
  end

  def test_mp3_inumber
    with_test_file('bad_name.mp3') do |f|
      out, = capture_io { Aur::Action.new(:info, [f]).run! }
      assert_match(/Track no : 2/, out)
      refute_match(/Track no : 11/, out)

      with_stdin do |input|
        input.puts "11\n"
        out, err = capture_io { Aur::Action.new(:inumber, [f]).run! }
        assert_empty(err)
        assert_equal(
          'bad_name.mp3 > ' \
          "       t_num -> 11\n" \
          "bad_name.mp3 -> 11.bad_name.mp3\n", out
        )
      end

      refute(f.exist?)
      new_file = TMP_DIR + '11.bad_name.mp3'
      assert new_file.exist?

      out, err = capture_io { Aur::Action.new(:info, [new_file]).run! }
      assert_empty(err)
      refute_match(/Track no : 2/, out)
      assert_match(/Track no : 11/, out)
    end
  end

  def action
    :inumber
  end
end

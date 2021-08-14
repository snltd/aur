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
        assert_output(
          '01.the_null_set.song_one.flac > ' \
          "       t_num -> 4\n" \
          "01.the_null_set.song_one.flac -> 04.the_null_set.song_one.flac\n",
          ''
        ) do
          Aur::Action.new(:inumber, [f]).run!
        end
      end

      refute(f.exist?)
      new_file = TMP_DIR + '04.the_null_set.song_one.flac'
      assert new_file.exist?

      assert_output(/Track no : 4$/, '') do
        Aur::Action.new(:info, [new_file]).run!
      end
    end
  end

  def test_mp3_inumber
    with_test_file('bad_name.mp3') do |f|
      assert_output(/Track no : 2/, '') { Aur::Action.new(:info, [f]).run! }

      with_stdin do |input|
        input.puts "11\n"
        assert_output('bad_name.mp3 > ' \
                      "       t_num -> 11\n" \
                      "bad_name.mp3 -> 11.bad_name.mp3\n", '') do
                        Aur::Action.new(:inumber, [f]).run!
                      end
      end

      refute(f.exist?)
      new_file = TMP_DIR + '11.bad_name.mp3'
      assert new_file.exist?

      assert_output(/Track no : 11/, '') { Aur::Action.new(:info, [f]).run! }
    end
  end

  def action
    :inumber
  end
end

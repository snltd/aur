#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur mp3dir' commands against real directories, and verify the results.
#
class TestMp3dir < MiniTest::Test
  #
  # This might look a bit i_suck_and_my_tests_are_order_dependent, but I swear
  # it's fine. It saves me having to carry around a stack of different
  # half-populated directories.
  #
  def test_mp3dir
    skip unless BIN[:flac].exist?
    skip unless BIN[:lame].exist?

    with_test_file('mp3dir') do |dir|
      source_dir = dir + 'flac' + 'artist.first_album'
      expected_dir = dir + 'mp3' + 'artist.first_album'
      assert(source_dir.exist?)
      refute(expected_dir.exist?)

      assert_output("#{source_dir + '01.artist.song_1.flac'} -> " \
                    "#{expected_dir + '01.artist.song_1.mp3'}\n" \
                    "#{source_dir + '02.artist.song_2.flac'} -> " \
                    "#{expected_dir + '02.artist.song_2.mp3'}\n",
                    '') do
        act(source_dir)
      end

      assert expected_dir.exist?

      original_mtimes = expected_dir.children.map(&:mtime)

      assert (expected_dir + '01.artist.song_1.mp3').exist?
      assert (expected_dir + '02.artist.song_2.mp3').exist?

      assert_equal(
        Aur::FileInfo.new(source_dir + '01.artist.song_1.flac').our_tags,
        Aur::FileInfo.new(expected_dir + '01.artist.song_1.mp3').our_tags
      )

      # Running again should do nothing, because the MP3s already exist
      #
      assert_silent { act(source_dir) }
      assert_equal(original_mtimes, expected_dir.children.map(&:mtime))

      # Now remove one file and run again. It should be replaced, and the
      # other should be left alone
      #
      (expected_dir + '02.artist.song_2.mp3').unlink

      assert_output("#{source_dir + '02.artist.song_2.flac'} -> " \
                    "#{expected_dir + '02.artist.song_2.mp3'}\n",
                    '') do
        act(source_dir)
      end

      assert_equal(
        original_mtimes.first, (expected_dir + '01.artist.song_1.mp3').mtime
      )

      refute_equal(
        original_mtimes.last,
        (expected_dir + '02.artist.song_2.mp3').mtime
      )

      # Running with -f should overwrite both files
      #
      assert_output("#{source_dir + '01.artist.song_1.flac'} -> " \
                    "#{expected_dir + '01.artist.song_1.mp3'}\n" \
                    "#{source_dir + '02.artist.song_2.flac'} -> " \
                    "#{expected_dir + '02.artist.song_2.mp3'}\n",
                    '') do
        act(source_dir, force: true)
      end

      refute_equal(original_mtimes, expected_dir.children.map(&:mtime))
    end
  end

  def test_mp3dir_tidy_up
    skip unless BIN[:flac].exist?
    skip unless BIN[:lame].exist?

    with_test_file('mp3dir') do |dir|
      source_dir = dir + 'flac' + 'artist.first_album'
      expected_dir = dir + 'mp3' + 'artist.first_album'

      FileUtils.mkdir_p(expected_dir)
      bonus = expected_dir + '03.artist.rubbish_bonus_track.mp3'

      FileUtils.cp(RES_DIR + 'test_tone-100hz.mp3', bonus)

      assert(source_dir.exist?)
      assert(expected_dir.exist?)
      assert(bonus.exist?)

      assert_output("#{source_dir + '01.artist.song_1.flac'} -> " \
                    "#{expected_dir + '01.artist.song_1.mp3'}\n" \
                    "#{source_dir + '02.artist.song_2.flac'} -> " \
                    "#{expected_dir + '02.artist.song_2.mp3'}\n" \
                    "Removing #{bonus}\n",
                    '') do
        act(source_dir)
      end

      assert expected_dir.exist?

      assert (expected_dir + '01.artist.song_1.mp3').exist?
      assert (expected_dir + '02.artist.song_2.mp3').exist?
      refute bonus.exist?
    end
  end

  def action
    :mp3dir
  end

  def act(dirs, opts = {})
    opts[:'<directory>'] = [dirs].flatten

    Aur::Action.new(action, [], opts).run!
  end
end

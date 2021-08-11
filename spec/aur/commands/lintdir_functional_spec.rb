#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

FDIR = RES_DIR + 'lintdir' + 'flac'
MDIR = RES_DIR + 'lintdir' + 'mp3'

# Run 'aur lintdir' commands against a mock filesystem, and verify the
# results.
#
class TestLintdirCommand < MiniTest::Test
  def test_directory_which_is_good
    out, err = capture_io { act(MDIR + 'broadcast.pendulum') }
    assert_empty(out)
    assert_empty(err)
  end

  def test_directory_which_only_holds_other_directories
    out, err = capture_io { act(FDIR) }
    assert_empty(out)
    assert_empty(err)
  end

  def test_directory_which_does_not_exist
    out, err = capture_io { act(RES_DIR + 'no_such_dir') }
    assert_empty(out)
    assert_equal("'#{RES_DIR}/no_such_dir' not found.\n", err)
  end

  def test_directory_with_a_bad_name
    out, err = capture_io { act(MDIR + 'polvo.cor.crane_secret') }
    assert_empty(out)
    assert_empty(err)
  end

  def test_directory_with_a_missing_file
    out, err = capture_io { act(MDIR + 'tegan_and_sara.the_con') }
    assert_empty(out)
    assert_equal("Missing files in #{MDIR + 'tegan_and_sara.the_con'}: " \
                 "expected 14, got 13\n", err)
  end

  def test_directory_with_a_wrongly_numbered_file
    out, err = capture_io { act(MDIR + 'seefeel.starethrough_ep') }
    assert_empty(out)
    assert_equal("Track number '02' not found\n", err)
  end

  def test_directory_with_missing_artwork
    out, err = capture_io { act(FDIR + 'fall.eds_babe') }
    assert_empty(out)
    assert_equal("Missing cover art in #{FDIR + 'fall.eds_babe'}\n", err)
  end

  def test_directory_with_artwork_that_should_not_be_there
    out, err = capture_io { act(MDIR + 'afx.analogue_bubblebath') }
    assert_empty(out)
    assert_equal("Unwanted cover art in #{MDIR + 'afx.analogue_bubblebath'}\n",
                 err)
  end

  def test_directory_with_junk_in
    out, err = capture_io { act(MDIR + 'pram.meshes') }
    assert_empty(out)
    assert_equal(
      "Bad file(s) in #{MDIR + 'pram.meshes'}:\n" \
      "  #{MDIR + 'pram.meshes' + 'some_junk.txt'}\n" \
      "  #{MDIR + 'pram.meshes' + 'some_more_junk.txt'}\n",
      err)
  end

  def test_directory_with_mixed_filetypes
    out, err = capture_io { act(MDIR + 'heavenly.atta_girl') }
    assert_empty(out)
    assert_equal("Different file types in #{MDIR + 'heavenly.atta_girl'}\n",
                 err)
  end


  private

  def act(*dirs)
    Aur::Action.new(:lintdir, [], { '<directory>': dirs }).run!
  end
end

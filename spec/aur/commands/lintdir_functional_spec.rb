#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

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
    assert_equal(
      "#{MDIR + 'polvo.cor.crane_secret'}: Invalid directory name\n",
      err
    )
  end

  def test_directory_with_a_missing_file
    out, err = capture_io { act(MDIR + 'tegan_and_sara.the_con') }
    assert_empty(out)
    assert_equal(
      "#{MDIR + 'tegan_and_sara.the_con'}: Missing file(s) (13/14)\n",
      err
    )
  end

  def test_directory_with_a_wrongly_numbered_file
    out, err = capture_io { act(MDIR + 'seefeel.starethrough_ep') }
    assert_empty(out)
    assert_equal("#{MDIR + 'seefeel.starethrough_ep'}: Missing track 02\n", err)
  end

  def test_directory_with_missing_artwork
    out, err = capture_io { act(FDIR + 'fall.eds_babe') }
    assert_empty(out)
    assert_equal("#{FDIR + 'fall.eds_babe'}: Missing cover art\n", err)
  end

  def test_directory_with_artwork_that_should_not_be_there
    out, err = capture_io { act(MDIR + 'afx.analogue_bubblebath') }
    assert_empty(out)
    assert_equal("#{MDIR + 'afx.analogue_bubblebath'}: Unwanted cover art\n",
                 err)
  end

  def test_directory_with_junk_in
    out, err = capture_io { act(MDIR + 'pram.meshes') }
    assert_empty(out)
    assert_equal(
      "#{MDIR + 'pram.meshes'}: Bad file(s)\n" \
      "  #{MDIR + 'pram.meshes' + 'some_junk.txt'}\n" \
      "  #{MDIR + 'pram.meshes' + 'some_more_junk.txt'}\n",
      err
    )
  end

  def test_directory_with_mixed_filetypes
    out, err = capture_io { act(MDIR + 'heavenly.atta_girl') }
    assert_empty(out)
    assert_equal("#{MDIR + 'heavenly.atta_girl'}: Different file types\n", err)
  end

  def test_recursion
    expected = <<~EOOUT
      #{MDIR}/afx.analogue_bubblebath: Unwanted cover art
      #{MDIR}/heavenly.atta_girl: Different file types
      #{MDIR}/polvo.cor.crane_secret: Invalid directory name
      #{MDIR}/pram.meshes: Bad file(s)
        #{MDIR}/pram.meshes/some_junk.txt
        #{MDIR}/pram.meshes/some_more_junk.txt
      #{MDIR}/seefeel.starethrough_ep: Missing track 02
      #{MDIR}/tegan_and_sara.the_con: Missing file(s) (13/14)
    EOOUT

    out, err = capture_io do
      Aur::Action.new(:lintdir, [], { '<directory>': [MDIR],
                                      recurse: true }).run!
    end

    assert_empty(out)
    assert_equal(
      expected,
      err
    )
  end

  private

  def act(*dirs)
    Aur::Action.new(:lintdir, [], { '<directory>': dirs }).run!
  end
end

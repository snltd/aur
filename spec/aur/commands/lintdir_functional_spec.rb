#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur lintdir' commands against a mock filesystem, and verify the
# results.
#
class TestLintdirCommand < Minitest::Test
  FDIR = RES_DIR.join('lintdir', 'flac')
  MDIR = RES_DIR.join('lintdir', 'mp3')
  ADIR = RES_DIR.join('lintdir-artwork')

  def test_directory_which_is_good
    assert_silent { act(MDIR.join('broadcast.pendulum')) }
  end

  def test_directory_which_only_holds_other_directories
    assert_silent { act(FDIR) }
  end

  def test_directory_with_two_discs
    assert_silent do
      act(MDIR.join('pet_shop_boys.very', 'further_listening_1992-1994'))
    end
  end

  def test_directory_which_does_not_exist
    assert_output('', "'#{RES_DIR}/no_such_dir' not found.\n") do
      act(RES_DIR.join('no_such_dir'))
    end
  end

  def test_directory_with_a_bad_name
    assert_output('', /polvo.cor.crane_secret\s+Invalid directory name\n/) do
      act(MDIR.join('polvo.cor.crane_secret'))
    end
  end

  def test_directory_with_a_missing_file
    assert_output('',
                  %r{tegan_and_sara.the_con\s+Missing file\(s\) \(13/14\)\n}) do
      act(MDIR.join('tegan_and_sara.the_con'))
    end
  end

  def test_directory_with_a_wrongly_numbered_file
    assert_output('', /seefeel.starethrough_ep\s+Missing track 02\n/) do
      act(MDIR.join('seefeel.starethrough_ep'))
    end
  end

  def test_directory_with_missing_artwork
    assert_output('', /#{FDIR.join('fall.eds_babe')}\s+Missing cover art\n/) do
      act(FDIR.join('fall.eds_babe'))
    end
  end

  def test_directory_with_junk_in
    expected = <<~EOOUT
      #{MDIR}/pram.meshes\\s+Bad file\\(s\\)
        #{MDIR}/pram.meshes/some_junk.txt
        #{MDIR}/pram.meshes/some_more_junk.txt
    EOOUT

    assert_output('', Regexp.new(expected, Regexp::MULTILINE)) do
      act(MDIR.join('pram.meshes'))
    end
  end

  def test_directory_with_mixed_filetypes
    assert_output('', /heavenly.atta_girl\s+Different file types\n/) do
      act(MDIR.join('heavenly.atta_girl'))
    end
  end

  def test_all_same_tags
    assert_output('', /Inconsistent album tag\n/) do
      act(FDIR.join('tester.different_album'))
    end

    assert_output('', /Inconsistent genre tag\n/) do
      act(FDIR.join('tester.different_genre'))
    end

    assert_output('', /Inconsistent year tag\n/) do
      act(FDIR.join('tester.different_year'))
    end
  end

  def test_artwork
    assert_silent { act(ADIR.join('tester.jpg_artwork')) }

    assert_output('', /Bad file/) { act(ADIR.join('tester.png_artwork')) }
  end

  # For reasons I cannot yet explain, this test and the next one pass
  # everywhere except in GitHub Actions
  #
  def _test_directory_with_artwork_that_should_not_be_there
    assert_output('', /afx.analogue_bubblebath\s+Unwanted cover art\n/) do
      act(MDIR.join('afx.analogue_bubblebath'))
    end
  end

  def _test_recursion
    expected = <<~EOOUT
      #{MDIR}/afx.analogue_bubblebath\\s+Unwanted cover art
      #{MDIR}/heavenly.atta_girl\\s+Different file types
      #{MDIR}/polvo.cor.crane_secret\\s+Invalid directory name
      #{MDIR}/pram.meshes\\s+Bad file\\(s\\)
        #{MDIR}/pram.meshes/some_junk.txt
        #{MDIR}/pram.meshes/some_more_junk.txt
      #{MDIR}/seefeel.starethrough_ep\\s+Missing track 02
      #{MDIR}/tegan_and_sara.the_con\\s+Missing file\\(s\\) \\(13\\/14\\)
    EOOUT

    assert_output('', Regexp.new(expected, Regexp::MULTILINE)) do
      Aur::Action.new(:lintdir, [], { '<directory>': [MDIR.to_s],
                                      recursive: true }).run!
    end
  end

  private

  def act(*dirs)
    Aur::Action.new(:lintdir, [], { '<directory>': dirs }).run!
  end
end

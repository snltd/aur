#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur lint' commands against known entities
#
class TestLintCommand < MiniTest::Test
  def test_good_flac
    assert_silent { act(RES_DIR + '03.null_set.high_beam.flac') }
  end

  def test_good_mp3
    assert_silent { act(RES_DIR + '03.null_set.high_beam.mp3') }
  end

  def test_missing_tags
    setup_test_dir
    FileUtils.cp(FLAC_TEST, TMP_DIR + '01.artist.song.flac')

    assert_output('', /Bad tags: date, genre/) do
      act(TMP_DIR + '01.artist.song.flac')
    end

    cleanup_test_dir
  end

  def test_good_flac_with_bad_name
    assert_output('', /Invalid file name$/) { act(FLAC_TEST) }
  end

  def test_good_mp3_with_bad_name
    assert_output('', /Invalid file name$/) { act(MP3_TEST) }
  end

  private

  def act(*files)
    Aur::Action.new(:lint, files).run!
  end
end

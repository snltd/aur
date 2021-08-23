#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur lint' commands against known entities
#
class TestLintCommand < MiniTest::Test
  def test_good_flac
    assert_silent do
      act(RES_DIR + 'null_set.some_stuff_by' + '03.null_set.high_beam.flac')
    end
  end

  def test_good_mp3
    assert_silent do
      act(RES_DIR + 'null_set.some_stuff_by' + '03.null_set.high_beam.mp3')
    end
  end

  def test_missing_tags_and_wrong_album
    file = RES_DIR + 'lint' + '03.test_artist.missing_tags.flac'

    out, err = capture_io { act(file) }
    assert_empty(out)

    assert_match(/#{file}\s+Bad tag value: t_num/, err)
    assert_match(/#{file}\s+Bad tag value: genre/, err)
    assert_match(/#{file}\s+Bad tag value: year/, err)
    assert_equal(3, err.lines.count)
  end

  def test_good_flac_with_bad_name
    assert_output('', /Invalid file name$/) do
      act(RES_DIR + 'test_tone-100hz.flac')
    end
  end

  def test_good_mp3_with_bad_name
    assert_output('', /Invalid file name$/) do
      act(RES_DIR + 'test_tone-100hz.mp3')
    end
  end

  private

  def act(*files)
    Aur::Action.new(:lint, files).run!
  end
end

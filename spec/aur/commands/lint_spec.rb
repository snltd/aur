#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/exception'
require_relative '../../../lib/aur/commands/lint'

# Test for lint
#
class TestLint < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::Command::Lint.new(RES_DIR + 'bad_name.flac')
  end

  def test_correctly_named?
    %w[
      01.artist.title.flac
      01.artist.title.mp3
      19.my_favourite_band.their_best_song.flac
      03.123.456.flac
      05.a_band.a_song-with_brackets.flac
      07.some_singer.i-n-i-t-i-a-l-s.flac
    ].each do |f|
      assert(t.correctly_named?(TMP_DIR + f), "#{f} should pass")
    end

    %w[
      artist.title.flac
      01.title.mp3
      19.my_favourite_band.their_best_song!.flac
      00.a_band.a_song-with_brackets.flac
      02.Artist.Title.flac
      03.someone_&_the_somethings.song.mp3
      04.too__many.underscores.flac
      1.artist.title.flac
      03._artist.title.mp3
      03.artist.title_.mp3
      03.artist.title_(with_brackets).flac
      07.the_somethings.i-n-i-t-i-a-l-s.flac
    ].each do |f|
      assert_raises(Aur::Exception::LintBadName, "#{f} should fail") do
        t.correctly_named?(TMP_DIR + f)
      end
    end
  end

  def test_correct_tags?
    assert t.correct_tags?

    capture_io do # because the MP3 library stderrs a warning
      assert_raises(Aur::Exception::LintBadTags) do
        Aur::Command::Lint.new(RES_DIR + 'unstripped.mp3').correct_tags?
      end
    end
  end

  def test_correct_tag_values?
    assert t.correct_tag_values?
  end
end

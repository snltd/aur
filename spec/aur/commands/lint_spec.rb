#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/exception'
require_relative '../../../lib/aur/commands/lint'

# Tests for linting album and EP files
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
      err = assert_raises(Aur::Exception::LintMissingTags) do
        Aur::Command::Lint.new(RES_DIR + 'missing_tags.mp3').correct_tags?
      end

      assert_equal('tcon', err.message)
    end

    capture_io do
      err = assert_raises(Aur::Exception::LintUnwantedTags) do
        Aur::Command::Lint.new(RES_DIR + 'unstripped.mp3').correct_tags?
      end

      assert_equal('tenc, tcom, txxx, apic', err.message)
    end
  end

  def test_correct_tag_values?
    assert t.correct_tag_values?
  end
end

# Tests for linting files in tracks/
#
class TestLintTracks < MiniTest::Test
  attr_reader :t

  L_DIR = RES_DIR + 'lint' + 'tracks'

  def setup
    @t = Aur::Command::Lint.new(L_DIR + 'album_file.flac')
  end

  def test_correctly_named?
    %w[
      artist.title.flac
      artist.title.mp3
      my_favourite_band.their_best_song.flac
      123.456.flac
      a_band.a_song-with_brackets.flac
      some_singer.i-n-i-t-i-a-l-s.flac
    ].each do |f|
      assert(t.correctly_named?(L_DIR + f), "#{f} should pass")
    end

    %w[
      01.artist.title.flac
      01.artist.title.mp3
      title.mp3
      my_favourite_band.their_best_song!.flac
      Artist.Title.flac
      someone_&_the_somethings.song.mp3
      too__many.underscores.flac
      _artist.title.mp3
      artist.title_.mp3
      artist.title_(with_brackets).flac
      the_somethings.i-n-i-t-i-a-l-s.flac
    ].each do |f|
      assert_raises(Aur::Exception::LintBadName, "#{f} should fail") do
        t.correctly_named?(L_DIR + f)
      end
    end
  end

  def test_correct_tags?
    assert t.correct_tags?

    capture_io do # because the MP3 library stderrs a warning
      assert_raises(Aur::Exception::LintMissingTags) do
        Aur::Command::Lint.new(L_DIR + 'missing_tags.mp3').correct_tags?
      end
    end
  end

  def test_correct_tag_values?
    err = assert_raises(Aur::Exception::InvalidTagValue) do
      t.correct_tag_values?
    end

    assert_equal('Album tag should not be set', err.message)
  end

  def test_validate_album_disc
    assert t.validate_album_disc('Album (Disc 1)', 'disc_1')
    assert t.validate_album_disc('(Disc 2 - Paris 1972-05-24)', 'disc_2')
    assert t.validate_album_disc('An Album', 'band.an_album')
    assert t.validate_album_disc('Black Sheep (Disc 1: Return of the Native)',
                                 'disc_1-return_of_the_native')

    err = assert_raises(Aur::Exception::InvalidTagValue) do
      t.validate_album_disc('Album', 'disc_2')
    end

    assert_equal(err.message,
                 'file in disc_ dir, but has no disc number in album tag')

    err = assert_raises(Aur::Exception::InvalidTagValue) do
      t.validate_album_disc('Album (Disc 1)', 'band.album')
    end

    assert_equal(err.message, 'album tag: disc 1 but not in disc_ dir')

    err = assert_raises(Aur::Exception::InvalidTagValue) do
      t.validate_album_disc('Album (Disc 1)', 'disc_2')
    end

    assert_equal(err.message, 'album tag: disc 1; directory disc 2')
  end
end

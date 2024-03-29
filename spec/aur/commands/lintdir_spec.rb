#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/exception'
require_relative '../../../lib/aur/commands/lintdir'

# Test for lintdir
#
class TestLintdir < Minitest::Test
  parallelize_me!

  T_DIR = Pathname.new('/tmp')

  def setup
    @t = Aur::Command::Lintdir.new
  end

  def test_correctly_named?
    good = %w[slint.spiderland smiths.the_smiths]
    bad = %w[Slint.Spiderland smiths.the.smiths the_smiths.the_smiths]

    good.each do |f|
      assert @t.correctly_named?(T_DIR.join(f))
    end

    bad.each do |f|
      assert_raises(Aur::Exception::LintDirBadName) do
        @t.correctly_named?(T_DIR.join(f))
      end
    end
  end

  def test_no_junk?
    assert @t.no_junk?([T_DIR.join('a/04.a.b.flac'),
                        T_DIR.join('a/01.a.b.flac')])

    assert @t.no_junk?([T_DIR.join('a/04.a.b.flac'),
                        T_DIR.join('a/front.jpg'),
                        T_DIR.join('a/01.a.b.flac')])

    assert_raises(Aur::Exception::LintDirBadFile) do
      @t.no_junk?([T_DIR.join('a/04.a.b.flac'),
                   T_DIR.join('a/front.png'),
                   T_DIR.join('a/01.a.b.flac')])
    end

    assert_raises(Aur::Exception::LintDirBadFile) do
      @t.no_junk?([T_DIR.join('a/04.a.b.flac'),
                   T_DIR.join('a/stuff.txt'),
                   T_DIR.join('a/01.a.b.flac')])
    end
  end

  def test_sequential_files?
    assert_raises(Aur::Exception::LintDirUnsequencedFile) do
      @t.sequential_files?([T_DIR.join('a/01.a.b.flac'),
                            T_DIR.join('a/03.a.b.flac'),
                            T_DIR.join('a/03.a.b.flac')])
    end
  end

  def test_expected_files?
    assert @t.expected_files?([T_DIR.join('a/02.a.b.flac'),
                               T_DIR.join('a/03.a.b.flac'),
                               T_DIR.join('a/01.a.b.flac')])

    assert @t.expected_files?([T_DIR.join('a/02.a.b.flac'),
                               T_DIR.join('a/front.png'),
                               T_DIR.join('a/03.a.b.flac'),
                               T_DIR.join('a/01.a.b.flac')])

    err = assert_raises(Aur::Exception::LintDirBadFileCount) do
      @t.expected_files?([T_DIR.join('a/01.a.b.flac'),
                          T_DIR.join('a/03.a.b.flac')])
    end

    assert_equal('2/3', err.message)
  end

  def test_all_same_filetype?
    assert @t.all_same_filetype?([T_DIR.join('a/04.a.b.flac'),
                                  T_DIR.join('a/01.a.b.flac')])

    assert @t.all_same_filetype?([T_DIR.join('a/04.a.b.flac'),
                                  T_DIR.join('a/front.jpg'),
                                  T_DIR.join('a/01.a.b.flac')])

    assert_raises(Aur::Exception::LintDirMixedFiles) do
      @t.all_same_filetype?([T_DIR.join('a/04.a.b.flac'),
                             T_DIR.join('a/01.a.b.mp3')])
    end
  end

  def test_highest_num
    assert_equal(11, @t.highest_number([T_DIR.join('a/04.a.b.flac'),
                                        T_DIR.join('a/01.a.b.flac'),
                                        T_DIR.join('a/03.a.b.flac'),
                                        T_DIR.join('a/11.a.b.flac')]))

    assert_equal(11, @t.highest_number([T_DIR.join('a/04.a.b.flac'),
                                        T_DIR.join('a/01.a.b.flac'),
                                        T_DIR.join('a/front.jpg'),
                                        T_DIR.join('a/03.a.b.flac'),
                                        T_DIR.join('a/11.a.b.flac')]))

    assert_equal(0, @t.highest_number([]))
  end

  def test_filenum
    assert_equal(5, @t.filenum(T_DIR.join('05.artist.song.flac')))
    assert_equal(11, @t.filenum(T_DIR.join('11.artist.song.mp3')))
  end

  def test_supported
    assert_equal([T_DIR.join('a/04.a.b.flac'),
                  T_DIR.join('a/01.a.b.mp3'),
                  T_DIR.join('a/01.a.b.flac')],
                 @t.supported([T_DIR.join('a/04.a.b.flac'),
                               T_DIR.join('a/01.a.b.mp3'),
                               T_DIR.join('a/front.jpg'),
                               T_DIR.join('a/01.a.b.flac')]))

    assert_equal([], @t.supported([T_DIR.join('a/03.a.b.wav'),
                                   T_DIR.join('a/01.a.b.MP3')]))
  end

  def test_cover_art
    assert @t.cover_art?([T_DIR.join('a/01.a.b.flac'),
                          T_DIR.join('a/front.jpg'),
                          T_DIR.join('a/02.a.b.flac')])

    assert_raises(Aur::Exception::LintDirCoverArtMissing) do
      @t.cover_art?([T_DIR.join('a/02.a.b.flac'),
                     T_DIR.join('a/01.a.b.flac')])
    end

    assert_raises(Aur::Exception::LintDirCoverArtUnwanted) do
      @t.cover_art?([T_DIR.join('a/01.a.b.mp3'),
                     T_DIR.join('a/front.jpg'),
                     T_DIR.join('a/02.a.b.mp3')])
    end
  end

  def test_cover_in
    assert @t.cover_in([T_DIR.join('a/01.a.b.flac'),
                        T_DIR.join('a/front.jpg'),
                        T_DIR.join('a/02.a.b.flac')])

    refute @t.cover_in([T_DIR.join('a/01.a.b.flac')])

    refute @t.cover_in([T_DIR.join('a/picture.jpg'),
                        T_DIR.join('a/01.a.b.flac')])
  end

  def test_various_artists?
    assert @t.various_artists?(T_DIR.join('a/b/various.compilation'))
    assert @t.various_artists?(T_DIR.join('a/b/these--them.split_single'))
    refute @t.various_artists?(T_DIR.join('a/b/singer.record'))
  end
end

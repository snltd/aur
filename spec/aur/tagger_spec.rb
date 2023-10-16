#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tagger'
require_relative '../../lib/aur/fileinfo'

# Ensure files are tagged correctly. Don't parallelize this, it breaks the
# spies.
#
class TestTagger < Minitest::Test
  T_DIR = RES_DIR.join('tagger')

  def setup
    @flac = Aur::FileInfo.new(T_DIR.join('test.flac'))
    @mp3 = Aur::FileInfo.new(T_DIR.join('test.mp3'))
  end

  def test_flac
    t = Aur::Tagger.new(@flac, {})

    del = Spy.on(t.info.raw, :comment_del)
    add = Spy.on(t.info.raw, :comment_add)
    upd = Spy.on(t.info.raw, :update!)

    assert_output(expected_output) { t.tag!(test_tags) }

    assert_equal(%w[ARTIST TITLE ALBUM TRACKNUMBER],
                 del.calls.map(&:args).flatten)

    assert_equal(['ARTIST=The Singer',
                  'TITLE=A Song',
                  'ALBUM=Their Record',
                  'TRACKNUMBER=3'],
                 add.calls.map(&:args).flatten)

    assert upd.has_been_called?
  end

  # The way the Mp3Info class is written makes it really hard to test. It
  # doesn't matter though. We have full functional tests.
  #
  def test_mp3
    t_mp3 = Aur::Tagger.new(@mp3, {})
    spy = Spy.on(Mp3Info, :open)
    # Because we Spy on the #open method and Mp3Info works on a block passed
    # to #open, nothing inside the loop (e.g. the calling of the #msg method)
    # happens, so there's really nothing to test. Just ensure it was called.

    t_mp3.tag!(test_tags)
    assert spy.has_been_called?
  end

  def test_validate
    t = Aur::Tagger.new(@flac, {})

    assert_equal({ artist: 'Prince' }, t.validate(artist: 'Prince'))
    assert_equal({ title: '1999' }, t.validate(title: '1999'))
    assert_equal({ album: '1999' }, t.validate(album: '1999'))
    assert_equal({ year: 1999 }, t.validate(year: '1999'))
    assert_equal({ year: 2021 }, t.validate(year: 2021))
    assert_equal({ t_num: 9 }, t.validate(t_num: '9'))
    assert_equal({ t_num: 1 }, t.validate(t_num: 1))
    assert_equal({ genre: 'Noise' }, t.validate(genre: 'Noise'))

    e = assert_raises(Aur::Exception::InvalidTagValue) do
      t.validate(year: '2050')
    end

    assert_equal("'2050' is an invalid year", e.message)

    e = assert_raises(Aur::Exception::InvalidTagValue) do
      t.validate(t_num: '0')
    end

    assert_equal("'0' is an invalid t_num", e.message)

    e = assert_raises(Aur::Exception::InvalidTagValue) { t.validate(t_num: -1) }
    assert_equal("'-1' is an invalid t_num", e.message)
  end

  def test_tags
    { artist: 'The Singer',
      title: 'A Song',
      album: 'Their Record',
      t_num: 3 }
  end

  def expected_output
    "      artist -> The Singer\n" \
      "       title -> A Song\n" \
      "       album -> Their Record\n" \
      "       t_num -> 3\n"
  end
end

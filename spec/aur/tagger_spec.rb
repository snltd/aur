#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tagger'
require_relative '../../lib/aur/fileinfo'

class TestTagger < MiniTest::Test
  attr_reader :t_mp3

  def setup
    mp3info = Aur::FileInfo.new(RES_DIR + 'test_tone-100hz.mp3')
    @t_mp3 = Aur::Tagger.new(mp3info, {})
  end

  def test_flac
    flacinfo = Aur::FileInfo.new(RES_DIR + 'test_tone-100hz.flac')
    t = Aur::Tagger.new(flacinfo, {})

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
    spy = Spy.on(Mp3Info, :open)
    # Because we Spy on the #open method and Mp3Info works on a block passed
    # to #open, nothing inside the loop (e.g. the calling of the #msg method)
    # happens, so there's really nothing to test. Just ensure it was called.

    t_mp3.tag!(test_tags)
    assert spy.has_been_called?
  end

  # def test_genre_id
  # assert_equal('(20)', t_mp3.genre_id('Alternative'))
  #
  # err = assert_raises(Aur::Exception::InvalidTagValue) do
  # t_mp3.genre_id('No Such Thing')
  # end
  #
  # assert_equal("'No Such Thing' is not a valid genre.", err.message)
  # end

  def test_validate
    flacinfo = Aur::FileInfo.new(RES_DIR + 'test_tone-100hz.flac')
    t = Aur::Tagger.new(flacinfo, {})

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
    assert_equal('2050', e.message)

    e = assert_raises(Aur::Exception::InvalidTagValue) do
      t.validate(t_num: '0')
    end
    assert_equal('0', e.message)

    e = assert_raises(Aur::Exception::InvalidTagValue) { t.validate(t_num: -1) }
    assert_equal('-1', e.message)
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

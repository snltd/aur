#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tag_validator'

# Ensure tags are validated correctly
#
class TestTagValidator < MiniTest::Test
  attr_reader :lax, :strict

  def setup
    @lax = Aur::TagValidator.new(nil, strict: false)
    @strict = Aur::TagValidator.new(
      Aur::FileInfo.new(
        RES_DIR.join('lint', '02.singer_and_the_band.file_for_test.flac')
      ),
      strict: true
    )
  end

  # lax linting uses the same methods for artist, album, and title, so there
  # this test does them all.
  #
  def test_artist_album_title_lax
    assert lax.artist('!!!')
    assert lax.artist('Broadcast')
    assert lax.artist('Simon and Garfunkel')
    assert lax.artist('Simon And Garfunkel')
    refute lax.artist('Broadcast;Broadcast')
    refute lax.artist('Simon & Garfunkel')
    refute lax.artist('')
    refute lax.artist(nil)
  end

  def test_artist_strict
    refute strict.artist('Singer and the Band')
  end

  def test_album_strict
    refute strict.album('Test Tones')
  end

  def test_title_strict
    assert strict.title('File for Test')
    refute strict.title('File For Test')
  end

  def test_t_num_lax
    assert lax.t_num('1')
    assert lax.t_num('10')
    refute lax.t_num('01')
    refute lax.t_num('-1')
    refute lax.t_num('')
    refute lax.t_num('0')
    refute lax.t_num('1/14')
    refute lax.t_num('01/14')
    refute lax.t_num('1 (disc 1)')
    refute lax.t_num(nil)
  end

  def test_t_num_strict
    assert strict.t_num('2')
    refute strict.t_num('02')
  end

  # year and genre are the same whether linting is strict or lax
  def test_year_lax
    assert lax.year('1994')
    assert lax.year(nil)
    refute lax.year(Time.now.year + 1)
    refute lax.year('1930')
    refute lax.year('')
    refute lax.year('1996/2020')
    refute lax.year('1989 02 03')
  end

  def test_genre_lax
    assert lax.genre('Alternative')
    assert lax.genre('Noise')
    assert lax.genre('Hip-Hop')
    assert lax.genre('Folk Rock')
    assert lax.genre('Rock and Roll')
    refute lax.genre('Folk rock')
    refute lax.genre('Hip-hop')
    refute lax.genre('Folk/Rock')
    refute lax.genre('noise')
    refute lax.genre('')
    refute lax.genre(nil)
    refute lax.genre('(20)')
  end
end

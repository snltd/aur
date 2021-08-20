#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tag_validator'

class TestTagValidator < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::TagValidator.new
  end

  def test_artist
    assert t.artist('!!!')
    assert t.artist('Broadcast')
    assert t.artist('Simon and Garfunkel')
    refute t.artist('Simon & Garfunkel')
    refute t.artist('')
    refute t.artist(nil)
  end

  def test_year
    assert t.year('1994')
    refute t.year(Time.now.year + 1)
    refute t.year('1930')
    refute t.year('')
    refute t.year('1996/2020')
    refute t.year('1989 02 03')
    refute t.year(nil)
  end

  def test_tracknum
    assert t.t_num('1')
    assert t.t_num('10')
    refute t.t_num('01')
    refute t.t_num('-1')
    refute t.t_num('')
    refute t.t_num('0')
    refute t.t_num('1/14')
    refute t.t_num('01/14')
    refute t.t_num('1 (disc 1)')
    refute t.t_num(nil)
  end

  def test_genre
    assert t.genre('Alternative')
    assert t.genre('Noise')
    assert t.genre('Hip-Hop')
    assert t.genre('Folk Rock')
    assert t.genre('Rock and Roll')
    refute t.genre('Folk rock')
    refute t.genre('Hip-hop')
    refute t.genre('Folk/Rock')
    refute t.genre('noise')
    refute t.genre('')
    refute t.genre(nil)
  end
end

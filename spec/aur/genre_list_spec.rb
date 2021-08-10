#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/genre_list'

# test the genre list gives the right results
#
class GenreListTest < MiniTest::Test
  def test_genre_list
    assert_equal('Electronic', GENRE_LIST[52])
    assert_equal('Indie', GENRE_LIST[131])
  end
end

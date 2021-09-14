#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/tagconv'

# Done with functional spec
#
class TestTagconv < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::Command::Tagconv.new(RES_DIR + 'test_tone-100hz.mp3')
  end

  def test_convert_tags
    assert_equal(
      { artist: 'Test',
        album: 'Test Album',
        title: '100hz',
        t_num: '6',
        year: '2021',
        genre: 'Noise' },
      t.convert_tags('title' => '100hz',
                     'artist' => 'Test',
                     'album' => 'Test Album',
                     'year' => 2021,
                     'comments' => 'Test file',
                     'tracknumber' => 6,
                     'genre' => 39,
                     'genre_s' => 'Noise')
    )
  end
end
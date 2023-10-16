#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/tagconv'

# Done with functional spec
#
class TestTagconv < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'tagconv')

  def test_convert_tags
    t = Aur::Command::Tagconv.new(T_DIR.join('test.mp3'))

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

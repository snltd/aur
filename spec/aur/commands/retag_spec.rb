#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/exception'
require_relative '../../../lib/aur/commands/retag'

# Test Retag command
#
class TestRetag < Minitest::Test
  parallelize_me!

  def setup
    @t = Aur::Command::Retag.new(RES_DIR.join('double_title.flac'))
  end

  def test_retag?
    assert @t.retag?(
      tag_names,
      { 'block_size' => 168,
        'offset' => 46,
        'vendor_tag' => 'reference libFLAC 1.2.1 20070917',
        'blank' => '  ',
        'title' => '100hz',
        'Album' => 'Test Tones',
        'Artist' => 'Test Tones',
        'TRACKNUMBER' => '6',
        'DATE' => '2021',
        'GENRE' => 'Noise',
        'TITLE' => 'other' }
    )

    assert @t.retag?(
      tag_names,
      { 'block_size' => 168,
        'offset' => 46,
        'vendor_tag' => 'reference libFLAC 1.2.1 20070917',
        'blank' => '  ',
        'album' => 'Test Tones',
        'artist' => 'Test Tones',
        'tracknumber' => '6',
        'date' => '2021',
        'genre' => 'Noise',
        'title' => 'other' }
    )

    refute @t.retag?(
      tag_names,
      { 'block_size' => 168,
        'offset' => 46,
        'vendor_tag' => 'reference libFLAC 1.2.1 20070917',
        'blank' => '  ',
        'ALBUM' => 'Test Tones',
        'ARTIST' => 'Test Tones',
        'TRACKNUMBER' => '6',
        'DATE' => '2021',
        'GENRE' => 'Noise',
        'TITLE' => 'other' }
    )
  end

  def tag_names
    { artist: 'ARTIST',
      album: 'ALBUM',
      title: 'TITLE',
      t_num: 'TRACKNUMBER',
      year: 'DATE',
      genre: 'GENRE' }
  end
end

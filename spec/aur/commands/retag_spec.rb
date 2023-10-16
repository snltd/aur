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
    @t = Aur::Command::Retag.new(UNIT_FLAC)
  end

  def test_retag_mixed_case
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
  end

  def test_retag_all_downcased
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
  end

  def test_retag_as_they_should_be
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

  private

  def tag_names
    { artist: 'ARTIST',
      album: 'ALBUM',
      title: 'TITLE',
      t_num: 'TRACKNUMBER',
      year: 'DATE',
      genre: 'GENRE' }
  end
end

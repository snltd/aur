#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/inumber'

# Tests
#
class TestInumber < MiniTest::Test
  attr_reader :totest

  def setup
    @totest = Aur::Inumber::Generic.new(FLAC_TEST)
  end

  def test_dest_file
    assert_equal(Pathname.new('/a/03.somefile.flac'),
                 totest.dest_file(3, Pathname.new('/a/somefile.flac')))
    assert_equal(Pathname.new('/a/04.somefile.flac'),
                 totest.dest_file(4, Pathname.new('/a/02.somefile.flac')))
    assert_equal(Pathname.new('/a/04.band.song.mp3'),
                 totest.dest_file(4, Pathname.new('/a/13.band.song.mp3')))
    assert_equal(RES_DIR + '19.test_tone-100hz.flac',
                 totest.dest_file(19, FLAC_TEST))
  end

  def test_validate
    assert_equal(5, totest.validate('5'))
    assert_equal(1, totest.validate('1'))
    assert_equal(19, totest.validate('19'))

    assert_raises(ArgumentError) { totest.validate('') }
    assert_raises(ArgumentError) { totest.validate('-1') }
    assert_raises(ArgumentError) { totest.validate('a') }
  end
end

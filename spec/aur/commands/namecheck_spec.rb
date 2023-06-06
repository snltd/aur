#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/namecheck'

# Test namecheck methods
#
class TestNamecheck < MiniTest::Test
  def setup
    @t = Aur::Command::Namecheck.new(RES_DIR.join('namecheck', 'flac', 'thes'))
  end

  def test_files
    assert(
      @t.files(RES_DIR.join('namecheck', 'flac')).all? do |f|
        f.extname == '.flac'
      end
    )

    assert(
      @t.files(RES_DIR.join('namecheck', 'mp3')).all? do |f|
        f.extname == '.mp3'
      end
    )

    assert_empty(@t.files(RES_DIR.join('namecheck', 'mp3', 'thes')))
  end

  def test_unique_list_of_artists
    out = @t.unique_list_of_artists(@t.instance_variable_get(:@files))
    assert_equal(['The Artist', 'Artist', 'Singer'], out.keys)
    assert(out.values.all? { |v| v.all?(Pathname) })
  end

  def test_thes
    assert_empty(@t.check_thes(
                   { 'Artist' => [Pathname.new('/a/a')],
                     'Band' => [Pathname.new('/a/b')],
                     'Chanteuse' => [Pathname.new('/a/c')] }
                 ))

    opt = Spy.on(@t, :output)

    @t.check_thes(
      { 'Artist' => [Pathname.new('/a/a')],
        'Band' => [Pathname.new('/a/b')],
        'Chanteuse' => [Pathname.new('/a/c')],
        'The Band' => [Pathname.new('/a/d')] }
    )

    assert_equal(1, opt.calls.size)
    assert_equal(
      ['The Band', [Pathname.new('/a/d')], 'Band', [Pathname.new('/a/b')]],
      opt.calls.first.args
    )
  end
end

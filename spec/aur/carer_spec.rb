#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require_relative '../spec_helper'
require_relative '../../lib/aur/carer'
require_relative '../../lib/aur/exception'

# test the carer
#
class CarerTest < Minitest::Test
  def setup
    @t = Aur::Carer.new(sample_data)
  end

  def test_do_we
    assert @t.do_we?(
      Aur::Exception::LintDirBadFileCount.new,
      Pathname.new('/storage/flac/albums/pqrs/stone_roses.second_coming')
    )

    refute @t.do_we?(
      Aur::Exception::LintDirBadFileCount.new,
      Pathname.new('/storage/flac/albums/pqrs/slint.spiderland')
    )

    refute @t.do_we?(
      Aur::Exception::LintDuplicateTags.new,
      Pathname.new('/storage/flac/albums/pqrs/stone_roses.second_coming')
    )
  end

  def test_lookup_key
    assert_equal(:LintBadName, @t.lookup_key(Aur::Exception::LintBadName.new))
  end

  def test_lookup_values
    assert_equal(
      ['eps/uilab.fires'],
      @t.lookup_values(Pathname.new('/storage/flac/eps/uilab.fires'))
    )

    assert_equal(
      ['albums/abc/clinic.do_it'],
      @t.lookup_values(Pathname.new('/storage/mp3/albums/abc/clinic.do_it'))
    )

    assert_equal(
      ['tracks/coil.tainted_love'],
      @t.lookup_values(
        Pathname.new('/storage/flac/tracks/coil.tainted_love.flac')
      )
    )
  end

  private

  def sample_data
    YAML.safe_load(File.read(RES_DIR.join('aur.yml')), symbolize_names: true)
  end
end

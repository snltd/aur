#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/num2name'

# Tests for num2name command
#
class TestNum2name < MiniTest::Test
  attr_reader :flac, :mp3

  def setup
    @flac = Aur::Command::Num2name.new(RES_DIR + 'test_tone-100hz.flac')
    @mp3 = Aur::Command::Num2name.new(RES_DIR + 'test_tone-100hz.mp3')
  end

  def test_run
    mv = Spy.on(FileUtils, :mv)

    assert_output("test_tone-100hz.flac -> 06.test_tone-100hz.flac\n", '') do
      flac.run
    end

    assert(mv.has_been_called?)
    assert_equal([RES_DIR + 'test_tone-100hz.flac',
                  RES_DIR + '06.test_tone-100hz.flac'],
                 mv.calls.first.args)
  end

  def test_new_filename_flac
    assert_equal('06.test_tone-100hz.flac', flac.new_filename)
  end

  def test_new_filename_mp3
    assert_equal('06.test_tone-100hz.mp3', mp3.new_filename)
  end

  def test_new_filename_flac_missing_data
    assert_equal('00.test_tone-100hz.flac',
                 flac.new_filename(TestTags.new({ title: 'Another Song' })))
  end

  def test_new_filename_mp3_all_data
    assert_equal('10.test_tone-100hz.mp3',
                 mp3.new_filename(
                   TestTags.new({ artist: 'Band', title: 'Song', t_num: '10' })
                 ))
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur thes' commands against things, and verify the results
#
class TestThesCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac_thes
    with_test_file('test_tone-100hz.flac') do |f|
      assert_tag(f, :artist, 'Test Tones')

      assert_output("      artist -> The Test Tones\n", '') do
        Aur::Action.new(:thes, [f]).run!
      end

      assert_tag(f, :artist, 'The Test Tones')

      assert_output('', '') { Aur::Action.new(:thes, [f]).run! }

      assert_tag(f, :artist, 'The Test Tones')
    end
  end

  def test_mp3_thes
    with_test_file('test_tone-100hz.mp3') do |f|
      assert_tag(f, :artist, 'Test Tones')

      assert_output("      artist -> The Test Tones\n", '') do
        Aur::Action.new(:thes, [f]).run!
      end

      assert_tag(f, :artist, 'The Test Tones')

      assert_output('', '') { Aur::Action.new(:thes, [f]).run! }

      assert_tag(f, :artist, 'The Test Tones')
    end
  end

  def action
    :thes
  end
end
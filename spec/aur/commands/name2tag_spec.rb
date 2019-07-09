#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/name2tag'

# Test for name2tag command
#
class TestName2Tag < MiniTest::Test
  attr_reader :flac, :mp3

  def setup
    @flac = Aur::Name2Tag::Flac.new(FLAC_TEST)
    @mp3 = Aur::Name2Tag::Mp3.new(MP3_TEST)
  end

  def test_run
    flac.run
    mp3.run
  end
end

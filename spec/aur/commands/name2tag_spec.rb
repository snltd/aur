#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/name2tag'

# Test for name2tag command
#
class TestName2tag < MiniTest::Test
  attr_reader :flac, :mp3

  def setup
    @flac = Aur::Name2tag::Flac.new(FLAC_TEST)
    @mp3 = Aur::Name2tag::Mp3.new(MP3_TEST)
  end
end

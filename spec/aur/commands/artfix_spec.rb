#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/artfix'

# Unit tests for Artfix class
#
class TestArtfix < MiniTest::Test
  def test_candidates
    t = Aur::Command::Artfix.new
    assert_equal(
      [AFDIR + 'albums/jesus_lizard.liar/cover.jpg',
       AFDIR + 'albums/windy_and_carl.portal/Front.JPG',
       AFDIR + 'eps/water_world.dead/front cover.Png'],
      t.candidates(AFDIR))

    assert_equal([], t.candidates(FDIR))
  end
end

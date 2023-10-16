#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur info' commands against things, and verify the output
#
class TestInfoCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'info')

  attr_reader :dir

  include Aur::CommandTests

  def test_flac_info
    assert_output(info_flac_test_output, '') do
      Aur::Action.new(
        action,
        [T_DIR.join('03.a_singer.this--is_a_test.flac')]
      ).run!
    end
  end

  def test_mp3_info
    assert_output(info_mp3_test_output, '') do
      Aur::Action.new(
        action,
        [T_DIR.join('02.imaginary_band.lets_sing_a_song.mp3')]
      ).run!
    end
  end

  def action = :info
end

# Ruby absolutely will not have these as heredocs. That single leading space
# trips it up.
#
def info_flac_test_output
  %( Filename : 03.a_singer.this--is_a_test.flac
     Type : FLAC
  Bitrate : 16-bit/44100Hz
     Time : 0.0
   Artist : A Singer
    Album : A Fictional LP
    Title : This (Is a Test)
    Genre : Pretend
 Track no : 3
     Year : 2023

)
end

def info_mp3_test_output
  %( Filename : 02.imaginary_band.lets_sing_a_song.mp3
     Type : MP3
  Bitrate : 106.66666666666667kbps (variable)
     Time : 0.1
   Artist : Imaginary Band
    Album : Unit Tester
    Title : Let's Sing a Song
    Genre : Ruby
 Track no : 2
     Year : 2021

)
end

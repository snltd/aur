#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur info' commands against things, and verify the output
#
class TestInfoCommand < MiniTest::Test
  attr_reader :dir

  include Aur::CommandTests

  def test_flac_info
    out, err = capture_io do
      Aur::Action.new(:info, [RES_DIR + 'bad_name.flac']).run!
    end

    assert_equal(bad_name_flac_info, out)
    assert_empty(err)
  end

  def test_mp3_info
    out, err = capture_io do
      Aur::Action.new(:info, [RES_DIR + 'bad_name.mp3']).run!
    end

    assert_equal(bad_name_mp3_info, out)
    assert_empty(err)
  end

  def action
    :info
  end
end

def bad_name_flac_info
  %( Filename : bad_name.flac
     Type : FLAC
  Bitrate : 16-bit/44100Hz
   Artist : The Null Set
    Album : Some Stuff By
    Title : Sammy Davis Jr. (Dancing)
    Genre : Electronic
 Track no : 2
     Year : 2021

)
end

def bad_name_mp3_info
  %( Filename : bad_name.mp3
     Type : MP3
  Bitrate : 199kbps (variable)
   Artist : The Null Set
    Album : Some Stuff By
    Title : Sammy Davis Jr. (Dancing)
    Genre : Blues
 Track no : 2
     Year : 2021

)
end

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
    assert_output(bad_name_flac_info, '') do
      Aur::Action.new(:info, [RES_DIR + 'bad_name.flac']).run!
    end
  end

  def test_mp3_info
    assert_output(bad_name_mp3_info, '') do
      Aur::Action.new(:info, [RES_DIR + 'bad_name.mp3']).run!
    end
  end

  def action
    :info
  end
end

# Ruby absolutely will not have these as heredocs. That single leading space
# trips it up.
#
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
    Genre : Electronic
 Track no : 2
     Year : 2021

)
end

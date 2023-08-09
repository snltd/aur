#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur info' commands against things, and verify the output
#
class TestTagsCommand < Minitest::Test
  attr_reader :dir

  include Aur::CommandTests

  def test_flac_info
    assert_output(bad_name_flac_info, '') do
      Aur::Action.new(action, [RES_DIR.join('bad_name.flac')]).run!
    end
  end

  def test_mp3_info
    assert_output(bad_name_mp3_info, '') do
      Aur::Action.new(action, [RES_DIR.join('bad_name.mp3')]).run!
    end
  end

  def action
    :tags
  end
end

def bad_name_flac_info
  %(         ALBUM : Some Stuff By
        ARTIST : The Null Set
    block_size : 171
          DATE : 2021
         GENRE : Electronic
        offset : 68
         TITLE : Sammy Davis Jr. (Dancing)
   TRACKNUMBER : 2
    vendor_tag : reference libFLAC 1.3.2 20170101
)
end

def bad_name_mp3_info
  %(   TALB : Some Stuff By
   TCON : Electronic
   TIT2 : Sammy Davis Jr. (Dancing)
   TPE1 : The Null Set
   TRCK : 2
   TYER : 2021
)
end

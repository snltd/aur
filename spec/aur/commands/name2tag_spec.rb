#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/name2tag'

# Test for name2tag command
#
class TestName2tag < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'name2tag')

  def test_flac
    SUPPORTED_TYPES.each do |type|
      t2 = Aur::Command::Name2tag.new(
        T_DIR.join('tester.badly_tagged', "01.tester.great_tags.#{type}")
      )

      assert_equal(
        { artist: 'Tester',
          title: 'Great Tags',
          album: 'Badly Tagged',
          t_num: '01' },
        t2.tags_from_filename
      )
    end
  end
end

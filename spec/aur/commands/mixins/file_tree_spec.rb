#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../../spec_helper'
require_relative '../../../../lib/aur/commands/mixins/file_tree'

# Tests for FileTree mixin
#
class Test < MiniTest::Test
  include Aur::Mixin::FileTree

  def test_content_under
    assert_equal(
      [
        [Pathname.new('fall.eds_babe'), 4],
        [Pathname.new('slint.spiderland_remastered'), 6],
        [Pathname.new('slint.spiderland_remastered/bonus_disc'), 14]
      ],
      content_under(RES_DIR + 'lintdir' + 'flac', '.flac')
    )

    assert_equal([], content_under(RES_DIR + 'lintdir' + 'flac', '.mp3'))
  end
end

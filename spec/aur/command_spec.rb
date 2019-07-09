#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/command'

# test the command controller
#
class CommandTest < MiniTest::Test
  attr_reader :obj

  def setup
    @obj = Aur::Command.new(:info, RES_DIR.children)
  end

  def test_action
    assert_equal(:Info, obj.action)
  end

  def test_flist
    assert(obj.flist.all? { |f| f.instance_of?(Pathname) })
    assert(obj.flist.all? { |f| %w[.flac .mp3].include?(f.extname) })
  end
end

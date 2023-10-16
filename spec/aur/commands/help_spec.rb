#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative '../../spec_helper'

# Test that every command gives some reasonable looking help.
#
class TestHelp < Minitest::Test
  parallelize_me!

  def test_help
    commands_to_test.each do |cmd|
      require cmd

      help = Object.const_get("Aur::Command::#{class_name(cmd)}").help

      assert_instance_of(String, help)

      assert_match(/^usage: aur #{class_name(cmd).downcase}/, help)
    end
  end

  def class_name(cmd)
    cmd.basename.to_s.split('.').first.capitalize
  end

  def commands_to_test
    command_dir.children.select do |f|
      f.extname == '.rb' && f.basename.to_s != 'base.rb' &&
        f.basename.to_s != 'help.rb'
    end
  end

  def command_dir
    Pathname.new(__dir__).parent.parent.parent.join('lib', 'aur', 'commands')
  end
end

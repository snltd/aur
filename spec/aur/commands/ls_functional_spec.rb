#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur ls' commands against a mock filesystem, and verify the results.
#
class TestLsCommand < MiniTest::Test
  FDIR = RES_DIR + 'lintdir' + 'flac'
  MDIR = RES_DIR + 'lintdir' + 'mp3'

  def test_empty_directory
    assert_silent { act(RES_DIR.parent) }
  end

  # rubocop:disable Layout/LineLength
  def test_directory
    assert_output(
      "03 The Null Set      High Beam                           Some Stuff By\n" \
      "03 The Null Set      High Beam                           Some Stuff By\n",
      ''
    ) do
      act(RES_DIR + 'null_set.some_stuff_by')
    end
  end
  # rubocop:enable Layout/LineLength

  def test_directory_machine_parseable
    assert_output(
      "03|The Null Set|High Beam|Some Stuff By\n" \
      "03|The Null Set|High Beam|Some Stuff By\n", ''
    ) do
      Aur::Action.new(
        :ls,
        [],
        '<directory>': [RES_DIR + 'null_set.some_stuff_by'], delim: '|'
      ).run!
    end
  end

  private

  def act(*dirs)
    Aur::Action.new(:ls, [], { '<directory>': dirs }).run!
  end
end

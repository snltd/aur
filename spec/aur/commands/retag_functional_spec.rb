#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur retag' commands against things, and verify the results
#
class TestRetagCommand < Minitest::Test
  include Aur::CommandTests

  def test_flac
    skip unless BIN[:metaflac].exist?

    with_test_file('double_title.flac') do |f|
      original = Aur::FileInfo.new(f)

      assert original.rawtags.key?('title')
      assert original.rawtags.key?('TITLE')

      assert_equal(10, original.tags.size)
      refute_equal(REQ_TAGS[:flac], original.tags.keys)

      expected_output = <<-EOOUT
      artist -> Test Tones
       album -> Test Tones
       title -> other
       t_num -> 6
        year -> 2021
       genre -> Noise
      EOOUT

      assert_output(expected_output, '') do
        Aur::Action.new(action, [f]).run!
      end

      new = Aur::FileInfo.new(f)
      refute new.rawtags.key?('title')
      assert new.rawtags.key?('TITLE')
      assert_nil(new.tags[:encoder])
    end
  end

  def test_flac_nothing_to_change
    with_test_file('retagged.flac') do |f|
      original = Aur::FileInfo.new(f)
      original_mtime = f.mtime

      assert_equal(REQ_TAGS[:flac].sort, original.tags.keys.sort)

      assert_silent do
        Aur::Action.new(action, [f]).run!
      end

      assert_equal(original_mtime, f.mtime)
    end
  end

  def action
    :retag
  end
end

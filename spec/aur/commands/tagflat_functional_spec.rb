#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur tagflat' commands against things, and verify the results
#
class TestTagflatCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac
    skip unless BIN[:metaflac].exist?

    with_test_file('double_title.flac') do |f|
      original = Aur::FileInfo.new(f)

      assert original.rawtags.key?('title')
      assert original.rawtags.key?('TITLE')

      #assert_equal(12, original.tags.size)
      #refute_equal(REQ_TAGS[:flac], original.tags.keys)
      #assert_equal('aur', original.tags[:encoder])

      #assert_output("Flattened tags\n", '') do
        Aur::Action.new(action, [f]).run!
      #end

      new = Aur::FileInfo.new(f)
      refute new.rawtags.key?('title')
      assert new.rawtags.key?('TITLE')
      #assert_equal(REQ_TAGS[:flac].sort, new.tags.keys.sort)
      #assert_nil(new.tags[:encoder])
    end
  end

  def test_flac_nothing_to_change
    with_test_file('bad_name.flac') do |f|
      original = Aur::FileInfo.new(f)
      original_mtime = f.mtime

      assert_equal(REQ_TAGS[:flac].sort, original.tags.keys.sort)

      assert_output('', '') { Aur::Action.new(action, [f]).run! }
      assert_equal(original_mtime, f.mtime)
    end
  end

  def action
    :tagflat
  end
end

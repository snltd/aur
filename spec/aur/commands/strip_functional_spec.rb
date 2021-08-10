#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur strip' commands against things, and verify the results
#
class TestStripCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac
    skip unless BIN[:metaflac].exist?

    with_test_file('unstripped.flac') do |f|
      original = Aur::FileInfo::Flac.new(f)

      assert original.picture?
      assert_equal(12, original.tags.size)
      refute_equal(REQ_TAGS[:flac], original.tags.keys)
      assert_equal('aur', original.tags[:encoder])

      out, err = capture_io { Aur::Action.new(:strip, [f]).run! }

      assert_equal("Surplus tags: composer, encoder, tempo\n", out)
      assert_empty(err)

      new = Aur::FileInfo::Flac.new(f)
      refute new.picture?
      assert_equal(REQ_TAGS[:flac].sort, new.tags.keys.sort)
      assert_nil(new.tags[:encoder])
    end
  end

  def test_flac_nothing_to_strip
    with_test_file('bad_name.flac') do |f|
      original = Aur::FileInfo::Flac.new(f)
      original_mtime = f.mtime

      refute original.picture?
      assert_equal(REQ_TAGS[:flac].sort, original.tags.keys.sort)

      out, err = capture_io { Aur::Action.new(:strip, [f]).run! }
      assert_empty(out)
      assert_empty(err)
      assert_equal(original_mtime, f.mtime)
    end
  end

  def test_mp3
    required_tags = { tit2: 'The Song',
                      tpe1: 'Singer',
                      trck: '3',
                      talb: 'Their Album',
                      tyer: '2021' }

    with_test_file('unstripped.mp3') do |f|
      original = Aur::FileInfo::Mp3.new(f)

      assert_equal(11, original.tags.size)
      refute_equal(required_tags, original.tags)
      assert_equal('Someone Clever', original.tags[:tcom])
      assert original.picture?

      out, _err = capture_io { Aur::Action.new(:strip, [f]).run! }

      assert_equal("Surplus tags: apic, tcom, tenc, tlen, tsse, txxx\n", out)
      # assert_empty(err) # the lib throws a warning on our test file

      new = Aur::FileInfo::Mp3.new(f)

      refute new.picture?
      assert_equal(required_tags, new.tags)
      refute(new.tags.key?(:tcom))
    end
  end

  def test_mp3_nothing_to_strip
    with_test_file('bad_name.mp3') do |f|
      original = Aur::FileInfo::Mp3.new(f)
      original_mtime = f.mtime

      refute original.picture?
      assert_equal(%i[tit2 tpe1 trck talb tcon tyer], original.tags.keys)

      out, err = capture_io { Aur::Action.new(:strip, [f]).run! }
      assert_empty(out)
      assert_empty(err)
      assert_equal(original_mtime, f.mtime)
    end
  end

  def action
    :strip
  end
end

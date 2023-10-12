#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur tagsub' commands against things, and verify the results
#
class TestTagsubCommand < Minitest::Test
  parallelize_me!

  include Aur::CommandTests

  def test_tagsub
    SUPPORTED_TYPES.each do |type|
      with_test_file("test_tone--100hz.#{type}") do |f|
        assert_tag(f, :artist, 'Test Tones')

        assert_output("      artist -> Test File\n", '') do
          tagsub_command(f, :artist, 'Tones', 'File')
        end

        assert_tag(f, :artist, 'Test File')
      end
    end
  end

  def test_tagsub_backref
    SUPPORTED_TYPES.each do |type|
      with_test_file("test_tone--100hz.#{type}") do |f|
        assert_tag(f, :artist, 'Test Tones')

        assert_output("       album -> New Tone Test\n", '') do
          tagsub_command(f, :album, '(\w+) (\w+)s', 'New \2 \1')
        end

        assert_tag(f, :album, 'New Tone Test')
      end
    end
  end

  def test_tagsub_no_change
    SUPPORTED_TYPES.each do |type|
      with_test_file("test_tone--100hz.#{type}") do |f|
        assert_tag(f, :artist, 'Test Tones')
        assert_silent { tagsub_command(f, :artist, 'Junk', 'Nonsense') }
        assert_tag(f, :artist, 'Test Tones')
      end
    end
  end

  def test_flac_tagsub_bad_tag
    assert_output('', "'badtag' tag not found.\n") do
      tagsub_command(RES_DIR.join('test_tone--100hz.flac'), :badtag, 'find',
                     'replace')
    end
  end

  def action
    :tagsub
  end
end

def tagsub_command(file, tag, find, replace)
  opts = { '<file>': file,
           '<tag>': tag,
           '<find>': find,
           '<replace>': replace }

  Aur::Action.new(:tagsub, [file], opts).run!
end

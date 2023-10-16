#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur itag' commands against things, and verify the results
#
class TestITagCommand < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'itag')

  include Aur::CommandTests

  def test_flac_inumber
    SUPPORTED_TYPES.each do |type|
      with_test_file(T_DIR.join("01.test_artist.untagged_song.#{type}")) do |f|
        out, = capture_io { Aur::Action.new(:info, [f]).run! }
        refute_match(/Title : New Title/, out)

        with_stdin do |input|
          input.puts "New Title\n"
          assert_output("#{f.basename}[title] > " \
                        "       title -> New Title\n" \
                        '') do
            Aur::Action.new(action, [f], '<tag>': 'title').run!
          end
        end

        with_stdin do |input|
          input.puts "New Artist   \n"
          assert_output("#{f.basename}[artist] > " \
                        "      artist -> New Artist\n" \
                        '') do
            Aur::Action.new(action, [f], '<tag>': 'artist').run!
          end
        end

        out, err = capture_io { Aur::Action.new(:info, [f]).run! }

        assert_match(/Title : New Title$/, out)
        assert_match(/Artist : New Artist$/, out)
        assert_empty(err)
      end
    end
  end

  def action = :itag
end

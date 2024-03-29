#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur inumber' commands against things, and verify the results
#
class TestINumberCommand < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'inumber')

  include Aur::CommandTests

  def test_flac_inumber
    SUPPORTED_TYPES.each do |type|
      fpart = "test_artist.untagged_song.#{type}"

      with_test_file(T_DIR.join("01.#{fpart}")) do |f|
        out, = capture_io { Aur::Action.new(:info, [f]).run! }
        refute_match(/Track no : 4/, out)

        with_stdin do |input|
          input.puts "4\n"
          assert_output(
            "01.#{fpart} > " \
            "       t_num -> 4\n" \
            "01.#{fpart} -> 04.#{fpart}\n",
            ''
          ) do
            Aur::Action.new(action, [f]).run!
          end
        end

        refute(f.exist?)
        new_file = f.dirname.join("04.#{fpart}")
        assert new_file.exist?

        assert_output(/Track no : 4$/, '') do
          Aur::Action.new(:info, [new_file]).run!
        end
      end
    end
  end

  def action = :inumber
end

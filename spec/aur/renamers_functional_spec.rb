#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/renamers'
require_relative '../../lib/aur/fileinfo'

# Renaming tests
#
class TestRenamersFunctional < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('renamers')

  include Aur::Renamers

  def test_rename_file_ok
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("01.test_artist.untagged_song.#{type}")
        target = dir.join("target_file.#{type}")

        assert f.exist?
        refute target.exist?

        out, err = capture_io { rename_file(f, target) }

        assert_equal("#{f.basename} -> #{target.basename}\n", out)
        assert_empty(err)

        refute f.exist?
        assert target.exist?
      end
    end
  end

  def test_rename_file_exists
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("01.test_artist.untagged_song.#{type}")
        target = dir.join("extant_file.#{type}")

        assert f.exist?
        assert target.exist?
        assert_equal("I got here first\n", File.read(target))
        assert_silent { rename_file(f, target) }
        assert_equal("I got here first\n", File.read(target))
        assert f.exist?
      end
    end
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/mp3dir'

# Tests for mp3dir class
#
class TestMp3dir < Minitest::Test
  def test_mp3_target_dir
    t = Aur::Command::Mp3dir.new(Pathname.new('/storage/flac/eps'))

    assert_equal(
      Pathname.new('/storage/mp3/eps/pram.meshes'),
      t.mp3_target_dir(Pathname.new('/storage/flac/eps/pram.meshes'))
    )

    assert_equal(
      Pathname.new('/flacs_and_mp3s/mp3/eps/abc.def'),
      t.mp3_target_dir(Pathname.new('/flacs_and_mp3s/flac/eps/abc.def'))
    )
  end

  def test_run_against_mp3_dirs
    assert_raises(Aur::Exception::InvalidInput) do
      Aur::Command::Mp3dir.new(RES_DIR)
    end
  end
end

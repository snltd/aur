#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/artfix'

# Unit tests for Artfix class
#
class TestArtfix < Minitest::Test
  parallelize_me!

  T_DIR = RES_DIR.join('commands', 'artfix')

  def setup
    @t = Aur::Command::Artfix.new
  end

  def test_image_files
    assert_equal(
      [T_DIR.join('albums', 'test.wrong_name/cover.jpg')],
      @t.image_files(T_DIR.join('albums', 'test.wrong_name'))
    )

    assert_equal(
      [T_DIR.join('albums', 'test.wrong_name--wrong_size/Front.JPG')],
      @t.image_files(T_DIR.join('albums', 'test.wrong_name--wrong_size'))
    )

    assert_equal(
      [],
      @t.image_files(T_DIR.join('albums', 'test.no_artwork'))
    )
  end

  def test_new_name
    %w[something.jpg something.jpeg something.Jpg something.JPG].each do |f|
      assert_equal(T_DIR.join('front.jpg'), @t.new_name(T_DIR.join(f)))
    end

    assert_raises(Aur::Exception::UnsupportedFiletype) do
      @t.new_name(T_DIR.join('something.png'))
    end
  end
end

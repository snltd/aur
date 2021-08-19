#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/fileinfo'
require_relative '../../lib/aur/tagger'

# Run tagger against real files and observe real changes
#
class TestTaggerFunctional < MiniTest::Test
  def test_flac_tagging
    with_test_file('test_tone-100hz.flac') do |f|
      info = Aur::FileInfo.new(f)
      file = Aur::Tagger.new(info)

      assert_equal('Test Tones', info.tags[:artist])
      assert_output(/\s+artist -> My Band\n/) { file.tag!(artist: 'My Band') }
      info = Aur::FileInfo.new(f)
      assert_equal('My Band', info.tags[:artist])

      e = assert_raises(Aur::Exception::InvalidTagName) do
        file.tag!(tracknumber: 4)
      end

      assert_equal('tracknumber', e.message)

      assert_equal(6, info.our_tags[:t_num].to_i)
      assert_output(/t_num -> 3/) { file.tag!(t_num: 3) }
      info = Aur::FileInfo.new(f)
      assert_equal(3, info.our_tags[:t_num].to_i)
    end
  end

  # Silently set all the tags on an initially untagged file.
  #
  def test_all_flac_tags
    with_test_file('01.the_null_set.song_one.flac') do |f|
      info = Aur::FileInfo.new(f)
      file = Aur::Tagger.new(info, quiet: true)

      assert_equal(
        { artist: nil,
          album: nil,
          title: nil,
          t_num: nil,
          year: nil,
          genre: nil },
        info.our_tags
      )

      assert file.tag!(artist: 'The Singer', title: 'Their Song')
      assert file.tag!(album: 'Difficult Second Album',
                       t_num: 5,
                       year: 2021,
                       genre: 'Pop')

      assert_equal(
        { artist: 'The Singer',
          album: 'Difficult Second Album',
          title: 'Their Song',
          t_num: '5',
          year: '2021',
          genre: 'Pop' },
        info.our_tags
      )
    end
  end

  def test_mp3_tagging
    with_test_file('test_tone-100hz.mp3') do |f|
      original = Aur::FileInfo.new(f)
      file = Aur::Tagger.new(original)

      assert_equal('Test Tones', original.artist)
      assert_output(/\s+artist -> My Band\n/) { file.tag!(artist: 'My Band') }

      new = Aur::FileInfo.new(f)
      assert_equal('My Band', new.artist)

      assert_equal('6', original.t_num)
      assert_output(/t_num -> 3/) { file.tag!(t_num: 3) }
      new = Aur::FileInfo.new(f)
      assert_equal('3', new.t_num)
    end
  end

  # Silently set all the tags on an initially untagged file.
  #
  def test_all_mp3_tags
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      info = Aur::FileInfo.new(f)
      file = Aur::Tagger.new(info, quiet: true)

      assert_equal(
        { artist: nil,
          album: nil,
          title: nil,
          t_num: nil,
          year: nil,
          genre: '(0)' },
        info.our_tags
      )

      assert file.tag!(artist: 'The Singer', title: 'Their Song')
      assert file.tag!(album: 'Difficult Second Album',
                       t_num: 5,
                       year: 2021,
                       genre: 'Pop')

      info = Aur::FileInfo.new(f)
      assert_equal(
        { artist: 'The Singer',
          album: 'Difficult Second Album',
          title: 'Their Song',
          t_num: '5',
          year: '2021',
          genre: 'Pop' },
        info.our_tags
      )
    end
  end
end

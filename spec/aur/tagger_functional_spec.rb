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
      info = Aur::FileInfo::Flac.new(f)
      file = Aur::Tagger::Flac.new(info)

      assert_equal('Test Tones', info.tags[:artist])
      out, err = capture_io { assert file.tag!(artist: 'My Band') }
      assert_equal("      artist -> My Band\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Flac.new(f)
      assert_equal('My Band', info.tags[:artist])

      e = assert_raises(Aur::Exception::InvalidTagName) do
        file.tag!(tracknumber: 4)
      end

      assert_equal('tracknumber', e.message)

      assert_equal(6, info.our_tags[:t_num].to_i)
      capture_io { assert file.tag!(t_num: 3) }
      info = Aur::FileInfo::Flac.new(f)
      assert_equal(3, info.our_tags[:t_num].to_i)
    end
  end

  # Silently set all the tags on an initially untagged file.
  #
  def test_all_flac_tags
    with_test_file('01.the_null_set.song_one.flac') do |f|
      info = Aur::FileInfo::Flac.new(f)
      file = Aur::Tagger::Flac.new(info, quiet: true)

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
      info = Aur::FileInfo::Mp3.new(f)
      file = Aur::Tagger::Mp3.new(info)

      assert_equal('Test Tones', info.tags[:artist])
      out, err = capture_io { assert file.tag!(artist: 'My Band') }
      assert_equal("      artist -> My Band\n", out)
      assert_empty(err)

      info2 = Aur::FileInfo::Mp3.new(f)
      assert_equal('My Band', info2.tags[:artist])

      assert_equal(6, info.our_tags[:t_num].to_i)
      capture_io { assert file.tag!(t_num: 3) }
      info3 = Aur::FileInfo::Mp3.new(f)
      assert_equal(3, info3.our_tags[:t_num].to_i)
    end
  end

  # Silently set all the tags on an initially untagged file.
  #
  def test_all_mp3_tags
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      info = Aur::FileInfo::Mp3.new(f)
      file = Aur::Tagger::Mp3.new(info, quiet: true)

      assert_equal(
        { artist: nil,
          album: nil,
          title: nil,
          t_num: nil,
          year: nil,
          genre: 'Blues' }, # I don't know why, yet.
        info.our_tags
      )

      assert file.tag!(artist: 'The Singer', title: 'Their Song')
      assert file.tag!(album: 'Difficult Second Album',
                       t_num: 5,
                       year: 2021,
                       genre: 'Pop')

      info = Aur::FileInfo::Mp3.new(f)
      assert_equal(
        { artist: 'The Singer',
          album: 'Difficult Second Album',
          title: 'Their Song',
          t_num: 5,
          year: 2021,
          genre: 'Pop' },
        info.our_tags
      )
    end
  end
end

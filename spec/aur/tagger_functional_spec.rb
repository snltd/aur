#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/fileinfo'
require_relative '../../lib/aur/tagger'

# Run tagger against real files and observe real changes
#
class TestTaggerFunctional < Minitest::Test
  T_DIR = RES_DIR.join('tagger')

  parallelize_me!

  def test_tagging
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("test.#{type}")
        info = Aur::FileInfo.new(f)
        file = Aur::Tagger.new(info)

        assert_equal('Test Tones', info.artist)
        assert_output(/\s+artist -> My Band\n/) { file.tag!(artist: 'My Band') }
        info = Aur::FileInfo.new(f)
        assert_equal('My Band', info.artist)

        e = assert_raises(Aur::Exception::InvalidTagName) do
          file.tag!(tracknumber: 4)
        end

        assert_equal("cannot validate 'tracknumber'", e.message)

        assert_equal(6, info.our_tags[:t_num].to_i)
        assert_output(/t_num -> 3/) { file.tag!(t_num: 3) }
        info = Aur::FileInfo.new(f)
        assert_equal(3, info.our_tags[:t_num].to_i)
      end
    end
  end

  # Silently set all the tags on an initially untagged file.
  #
  def test_all_tags
    with_test_file(T_DIR) do |dir|
      SUPPORTED_TYPES.each do |type|
        f = dir.join("01.test_artist.untagged_song.#{type}")
        info = Aur::FileInfo.new(f)
        file = Aur::Tagger.new(info, quiet: true)

        assert_equal(blank_tags[type.to_sym], info.our_tags)
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
            genre: 'Pop' }, Aur::FileInfo.new(f).our_tags
        )
      end
    end
  end

  private

  def blank_tags
    { flac: { artist: nil,
              album: nil,
              title: nil,
              t_num: nil,
              year: nil,
              genre: nil },
      mp3: { artist: nil,
             album: nil,
             title: nil,
             t_num: nil,
             year: nil,
             genre: 'Noise' } }
  end
end

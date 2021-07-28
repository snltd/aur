#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tagger'
require_relative '../../lib/aur/fileinfo'

class TestTagger < MiniTest::Test
  attr_reader :flac, :mp3

  # def setup
  # flacinfo = Aur::FileInfo::Flac.new(FLAC_TEST)
  # @flac = Aur::Tagger::Flac.new(flacinfo)
  #
  # mp3info = Aur::FileInfo::Mp3.new(MP3_TEST)
  # @mp3 = Aur::Tagger::Flac.new(mp3info)
  # end
  #
  # def test_flac
  # assert_equal(:title, flac.real_tagname(:title))
  # assert_equal(:tracknumber, flac.real_tagname(:t_num))
  #
  # assert_raises(ArgumentError) { flac.real_tagname(:singer) }
  # end
  #
  # def test_mp3
  # assert_equal(:title, mp3.real_tagname(:title))
  # assert_equal(:tracknum, mp3.real_tagname(:t_num))

  # assert_raises(ArgumentError) { mp3.real_tagname(:singer) }
  # end
end

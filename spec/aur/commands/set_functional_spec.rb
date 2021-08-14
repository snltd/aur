#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'

# Run 'aur set...' commands against things, and verify the results
#
class TestSetCommand < MiniTest::Test
  include Aur::CommandTests

  def test_flac_set
    with_test_file('01.the_null_set.song_one.flac') do |f|
      assert_output("      artist -> My Rubbish Band\n", '') do
        set_command(f, 'artist', 'My Rubbish Band')
      end

      info = Aur::FileInfo::Flac.new(f)
      assert_equal('My Rubbish Band', info.our_tags[:artist])

      assert_output("       title -> Some Lousy Song\n", '') do
        set_command(f, 'title', 'Some Lousy Song')
      end

      info = Aur::FileInfo::Flac.new(f)
      assert_equal('Some Lousy Song', info.our_tags[:title])

      assert_output("        year -> 2021\n", '') do
        set_command(f, 'year', '2021')
      end

      info = Aur::FileInfo::Flac.new(f)
      assert_equal('2021', info.our_tags[:year])

      assert_output("       t_num -> 5\n", '') { set_command(f, 't_num', '5') }

      info = Aur::FileInfo::Flac.new(f)
      assert_equal('5', info.our_tags[:t_num])

      assert_output("       genre -> Noise\n", '') do
        set_command(f, 'genre', 'Noise')
      end

      info = Aur::FileInfo::Flac.new(f)
      assert_equal('Noise', info.our_tags[:genre])

      assert_equal({ artist: 'My Rubbish Band',
                     album: nil,
                     title: 'Some Lousy Song',
                     t_num: '5',
                     year: '2021',
                     genre: 'Noise' }, info.our_tags)
    end
  end

  def test_mp3_set
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      assert_output("      artist -> My Rubbish Band\n", '') do
        set_command(f, 'artist', 'My Rubbish Band')
      end

      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('My Rubbish Band', info.our_tags[:artist])

      assert_output("       title -> Some Lousy Song\n", '') do
        set_command(f, 'title', 'Some Lousy Song')
      end

      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('Some Lousy Song', info.our_tags[:title])

      assert_output("        year -> 2021\n", '') do
        set_command(f, 'year', '2021')
      end

      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('2021', info.our_tags[:year])

      assert_output("       t_num -> 5\n", '') { set_command(f, 't_num', '5') }

      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('5', info.our_tags[:t_num])

      assert_output("       genre -> Noise\n", '') do
        set_command(f, 'genre', 'Noise')
      end

      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('Noise', info.our_tags[:genre])

      assert_equal({ artist: 'My Rubbish Band',
                     album: nil,
                     title: 'Some Lousy Song',
                     t_num: '5',
                     year: '2021',
                     genre: 'Noise' }, info.our_tags)
    end
  end

  def test_set_bad_tag
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      assert_output('', "'singer' is not a valid tag name.\n") do
        set_command(f, 'singer', 'Mouse Melon')
      end
    end
  end

  def test_set_invalid_tag
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      assert_outout('', "'Five' is an invalid value.\n") do
        set_command(f, 't_num', 'Five')
      end

      assert_output('', "'#{Time.now.year + 1}' is an invalid value.\n") do
        set_command(f, 'year', Time.now.year + 1)
      end
    end
  end

  def set_command(file, tag, value)
    opts = { '<file>': file, '<tag>': tag, '<value>': value }

    Aur::Action.new(:set, [file], opts).run!
  end

  def action
    :set
  end
end

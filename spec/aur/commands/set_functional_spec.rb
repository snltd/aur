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
      out, err = capture_io { set_command(f, 'artist', 'My Rubbish Band') }
      assert_equal("      artist -> My Rubbish Band\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Flac.new(f)
      assert_equal('My Rubbish Band', info.our_tags[:artist])

      out, err = capture_io { set_command(f, 'title', 'Some Lousy Song') }
      assert_equal("       title -> Some Lousy Song\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Flac.new(f)
      assert_equal('Some Lousy Song', info.our_tags[:title])

      out, err = capture_io { set_command(f, 'year', '2021') }
      assert_equal("        year -> 2021\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Flac.new(f)
      assert_equal('2021', info.our_tags[:year])

      out, err = capture_io { set_command(f, 't_num', '5') }
      assert_equal("       t_num -> 5\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Flac.new(f)
      assert_equal('5', info.our_tags[:t_num])

      out, err = capture_io { set_command(f, 'genre', 'Noise') }
      assert_equal("       genre -> Noise\n", out)
      assert_empty(err)
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
      out, err = capture_io { set_command(f, 'artist', 'My Rubbish Band') }
      assert_equal("      artist -> My Rubbish Band\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('My Rubbish Band', info.our_tags[:artist])

      out, err = capture_io { set_command(f, 'title', 'Some Lousy Song') }
      assert_equal("       title -> Some Lousy Song\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('Some Lousy Song', info.our_tags[:title])

      out, err = capture_io { set_command(f, 'year', '2021') }
      assert_equal("        year -> 2021\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('2021', info.our_tags[:year])

      out, err = capture_io { set_command(f, 't_num', '5') }
      assert_equal("       t_num -> 5\n", out)
      assert_empty(err)
      info = Aur::FileInfo::Mp3.new(f)
      assert_equal('5', info.our_tags[:t_num])

      out, err = capture_io { set_command(f, 'genre', 'Noise') }
      assert_equal("       genre -> Noise\n", out)
      assert_empty(err)
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
      out, err = capture_io { set_command(f, 'singer', 'Mouse Melon') }
      assert_empty(out)
      assert_equal("'singer' is not a valid tag name.\n", err)
    end
  end

  def test_set_invalid_tag
    with_test_file('01.the_null_set.song_one.mp3') do |f|
      out, err = capture_io { set_command(f, 't_num', 'Five') }
      assert_empty(out)
      assert_equal("'Five' is an invalid value.\n", err)

      out, err = capture_io { set_command(f, 'year', Time.now.year + 1) }
      assert_empty(out)
      assert_equal("'#{Time.now.year + 1}' is an invalid value.\n", err)
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

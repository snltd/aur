#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/strip'

# Test internals of strip command
#
class TestStrip < Minitest::Test
  parallelize_me!

  def test_real_tags
    t = Aur::Command::Strip.new(RES_DIR.join('test_tone--100hz.flac'))

    assert_equal(
      %w[Album TITLE iTunNORM iTunes_CDDB_IDs Title].sort,
      t.real_tags(
        ['Title=Lesson No.1 for Electric Guitar',
         'Artist=Glenn Branca',
         'Album=Lesson No. 1',
         'Genre=Classical',
         'Date=1980',
         'iTunNORM= 0000153A 00001A2A 000055FD 00007145 0004DA8A 0006B03E ' \
         '00007E86 00007E85 0006CA91 000703CC',
         'iTunes_CDDB_IDs=3+8BF9C0EE9DAFD4BD3BA24EACF1C3E02C+3894038',
         'Encoded By=dBpoweramp Release 13',
         'tracknumber=1',
         'GENRE=Avant Garde',
         'TITLE=Lesson No. 1 for Electric Guitar'],
        %i[album title itunnorm itunes_cddb_ids]
      ).sort
    )
  end
end

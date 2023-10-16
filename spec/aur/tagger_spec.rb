#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tagger'
require_relative '../../lib/aur/fileinfo'

# Ensure files are tagged correctly
#
class TestTagger < Minitest::Test
  T_DIR = RES_DIR.join('tagger')

  def test_validate
    t = Aur::Tagger.new(Aur::FileInfo.new(T_DIR.join('test.flac')), {})

    assert_equal({ artist: 'Prince' }, t.validate(artist: 'Prince'))
    assert_equal({ title: '1999' }, t.validate(title: '1999'))
    assert_equal({ album: '1999' }, t.validate(album: '1999'))
    assert_equal({ year: 1999 }, t.validate(year: '1999'))
    assert_equal({ year: 2021 }, t.validate(year: 2021))
    assert_equal({ t_num: 9 }, t.validate(t_num: '9'))
    assert_equal({ t_num: 1 }, t.validate(t_num: 1))
    assert_equal({ genre: 'Noise' }, t.validate(genre: 'Noise'))

    e = assert_raises(Aur::Exception::InvalidTagValue) do
      t.validate(year: '2050')
    end

    assert_equal("'2050' is an invalid year", e.message)

    e = assert_raises(Aur::Exception::InvalidTagValue) do
      t.validate(t_num: '0')
    end

    assert_equal("'0' is an invalid t_num", e.message)

    e = assert_raises(Aur::Exception::InvalidTagValue) { t.validate(t_num: -1) }
    assert_equal("'-1' is an invalid t_num", e.message)
  end
end

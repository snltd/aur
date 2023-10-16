#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/retitle'

# Tests the internals of the retitle command
#
class TestRetitle < Minitest::Test
  T_DIR = RES_DIR.join('commands', 'retitle')

  def test_retitle
    t = Aur::Command::Retitle.new(T_DIR.join('bad_name.flac'))

    assert_equal('Original Title', t.retitle('Original Title'))
    assert_equal('Fix the Article', t.retitle('Fix The Article'))
    assert_equal('One of the Ones Where We Fix a Word or Two',
                 t.retitle('One Of The Ones Where We Fix A Word Or Two'))
    assert_equal('This, that, and, Yes, the Other',
                 t.retitle('This, That, And, Yes, The Other'))
    assert_equal('It is is It', t.retitle('It Is Is It'))
    assert_equal('A: The Thing of Things',
                 t.retitle('A: The Thing Of Things'))
    assert_equal('One Thing / And the Other',
                 t.retitle('One Thing / And The Other'))
    assert_equal('It is Narrow Here', t.retitle('It Is Narrow here'))
    assert_equal(
      'The Song of the Nightingale / The Firebird Suite / The Rite of Spring',
      t.retitle(
        'The Song Of The Nightingale / The Firebird Suite / The Rite of Spring'
      )
    )
  end
end

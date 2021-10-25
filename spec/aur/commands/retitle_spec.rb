#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/commands/retitle'

# Tests the internals of the retitle command
#
class TestRetitle < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::Command::Retitle.new(RES_DIR + 'bad_name.flac')
  end

  def test_retitle
    assert_equal('Original Title', t.retitle('Original Title'))
    assert_equal('Fix the Article', t.retitle('Fix The Article'))
    assert_equal('One of the Ones Where We Fix a Word or Two',
                 t.retitle('One Of The Ones Where We Fix A Word Or Two'))
    assert_equal('This, that, and, Yes, the Other',
                 t.retitle('This, That, And, Yes, The Other'))
    assert_equal('It is is It', t.retitle('It Is Is It'))
    assert_equal('A: The Thing of Things',
                 t.retitle('A: The Thing Of Things'))
  end
end

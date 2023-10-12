#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/words'

# Tests for Words class
#
class TestWords < Minitest::Test
  parallelize_me!

  def test_words
    t = Aur::Words.new(example_conf)

    assert_includes(t.no_caps, 'on')
    assert_includes(t.no_caps, 'merp')
    refute_includes(t.all_caps, 'merp')

    assert_includes(t.all_caps, 'lp')
    assert_includes(t.all_caps, 'elp')

    assert_equal(t.expand.fetch(:isnt), "isn't")
    assert_equal(t.expand.fetch(:whats), "what's")
  end
end

def example_conf
  {
    tagging: {
      no_caps: %w[merp],
      all_caps: %w[elp ep],
      expand: { whats: "what's" }
    }
  }
end

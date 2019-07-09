#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/stdlib/string'

# Tests for String extensions
#
class StringTest < MiniTest::Test
  def test_to_safe
    assert_equal('', ''.to_safe)
    assert_equal('basic', 'basic'.to_safe)
    assert_equal('fuxa', 'Füxa'.to_safe)
    assert_equal('say_yes', 'Say "Yes!"'.to_safe)
    assert_equal('simple-string', 'simple-String'.to_safe)
    assert_equal('simple_string', 'Simple String'.to_safe)
    assert_equal('simple-string', 'Simple - String'.to_safe)
    assert_equal('a_long_complicated_string-type-thing',
                 'a long, complicated string-type-thing.'.to_safe)
    assert_equal('content', '!|~~c*o*n*t*e*n*t~~;:'.to_safe)
    assert_equal('looking_for_love-in_the_hall_of_mirrors',
                 'Looking for Love (in the Hall of Mirrors)'.to_safe)
    assert_equal('you_gotta-fight_for_your_right-to_party',
                 '(You Gotta) Fight for Your Right (to Party!)'.to_safe)
    assert_equal('this_is-almost-too_easy',
                 'this is (almost) too easy'.to_safe)
    assert_equal('im_almost_sure_youre_not',
                 "I'm almost sure you're not...".to_safe)
  end
end

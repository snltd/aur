#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/aur/stdlib/string'
require_relative '../../../lib/aur/constants'

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

  def test_expand
    assert_equal('normal', 'normal'.expand)
    assert_equal("isn't", 'isnt'.expand)
    assert_equal("Isn't", 'isnt'.expand(:caps))
  end

  def test_initials
    assert_equal('Y.M.C.A.', 'y-m-c-a'.initials)
    assert_equal('C.R.E.E.P.', 'c-r-e-e-p'.initials)
    assert_equal('X.', 'x'.initials)
  end

  def test_safe?
    %w[
      artist
      01
      a
      7
      me
      two_words
      and_three_words
      with-hyphen
      1_two_3
      one_2_3
    ].each { |c| assert(c.safe?, "#{c} should pass") }

    %w[
      _word
      -word
      _
      -
      word_
      two__words
      too--many--dashes
      tres,comma
      Word
    ].each { |c| refute(c.safe?, "#{c} should fail") }
  end

  def test_safenum
    assert '01'.safenum?
    assert '99'.safenum?
    refute '00'.safenum?
  end
end

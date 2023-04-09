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
    assert_equal('stripped_string', 'Stripped String  '.to_safe)
    assert_equal('a_long_complicated_string-type-thing',
                 'a long, complicated string-type-thing.'.to_safe)
    assert_equal('content', '!|~~c*o*n*t*e*n*t~~;:'.to_safe)
    assert_equal('looking_for_love--in_the_hall_of_mirrors',
                 'Looking for Love (in the Hall of Mirrors)'.to_safe)
    assert_equal('you_gotta--fight_for_your_right--to_party',
                 '(You Gotta) Fight for Your Right (to Party!)'.to_safe)
    assert_equal('this_is--almost--too_easy',
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
      some--bracketed--words
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
      tres,comma
      Word
    ].each { |c| refute(c.safe?, "#{c} should fail") }
  end

  def test_safenum
    assert '01'.safenum?
    assert '99'.safenum?
    refute '00'.safenum?
  end

  def test_titlecase
    assert_equal('Word', 'word'.titlecase)
    assert_equal('Word', 'Word'.titlecase)
    assert_equal('the', 'The'.titlecase)
    assert_equal('of', 'of'.titlecase)
    assert_equal('The', 'the'.titlecase('A:'))
    assert_equal('The', 'the'.titlecase('/'))
    assert_equal('and,', 'And,'.titlecase)
    assert_equal('(Disc,', '(disc,'.titlecase)
    assert_equal('I', 'i'.titlecase)
    assert_equal('a', 'a'.titlecase)
    assert_equal('L.A.', 'l.a.'.titlecase)
    assert_equal('P.R.O.D.U.C.T.', 'p.r.o.d.u.c.t.'.titlecase)
    assert_equal('(B.M.R.', '(B.M.R.'.titlecase)
    assert_equal('(A', '(A'.titlecase)
    assert_equal('(LP', '(LP'.titlecase)
    assert_equal('(Live)', '(live)'.titlecase)
    assert_equal('(II)', '(Ii)'.titlecase)
    assert_equal('OK', 'ok'.titlecase)
    assert_equal('Aikea-Guinea', 'Aikea-Guinea'.titlecase)
    assert_equal('Itchy+Scratchy', 'Itchy+scratchy'.titlecase)
    assert_equal('A-O', 'A-O'.titlecase)
    assert_equal('The', 'the'.titlecase('as)'))
    assert_equal('As)', 'as)'.titlecase)
    assert_equal('A:', 'A:'.titlecase('men?'))
    assert_equal('A,', 'A,')
    assert_equal('Fixed::Content', 'fixed::content'.titlecase)
    assert_equal('Kill-a-Man', 'kill-a-man'.titlecase)
    assert_equal('Master=Dik', 'Master=dik'.titlecase)
  end
end

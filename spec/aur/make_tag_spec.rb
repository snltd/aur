#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/make_tag'

class TestName2Tag < MiniTest::Test
  include Aur::MakeTag

  def test_mk_title_plain
    assert_equal('Pet Shop Boys', mk_title('pet_shop_boys'))
  end

  def test_mk_title_the
    assert_equal('The Boy with the Arab Strap',
                 mk_title('the_boy_with_the_arab_strap'))
  end

  def test_mk_title_last_word_preposition
    assert_equal('I Want to Wake Up', mk_title('i_want_to_wake_up'))
  end

  def test_mk_title_contraction
    assert_equal("Don't Let Our Youth Go to Waste",
                 mk_title('dont_let_our_youth_go_to_waste'))
    assert_equal("You Can't Hold What You Haven't Got in Your Hand",
                 mk_title('you_cant_hold_what_you_havent_got_in_your_hand'))
  end

  def test_mk_title_brackets_at_end
    assert_equal('Suburbia (The Full Horror)',
                 mk_title('suburbia-the_full_horror'))
  end

  def test_mk_title_brackets_in_middle
    assert_equal('This Is (Almost) Too Easy',
                 mk_title('this_is-almost-too_easy'))
    assert_equal('Can We Make It (Just a Little Bit) Harder',
                 mk_title('can_we_make_it-just_a_little_bit-harder'))
    assert_equal('Title Ending In (Bracketed Words)',
                 mk_title('title_ending_in-bracketed_words'))
    assert_equal('The (I.N.I.T.I.A.L.S.) In Brackets',
                 mk_title('the-i-n-i-t-i-a-l-s-in_brackets'))
    assert_equal('Two (Lots) Of Brackets (Is Tricky)',
                 mk_title('two-lots-of_brackets-is_tricky'))
  end

  def test_mk_title_initials
    assert_equal('C.R.E.E.P.', mk_title('c-r-e-e-p'))
    assert_equal('The N.W.R.A.', mk_title('the_n-w-r-a'))
    assert_equal('W.M.C. Blob 59', mk_title('w-m-c_blob_59'))
  end
end

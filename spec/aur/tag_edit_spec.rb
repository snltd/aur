#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tag_edit'

class TestName2Tag < MiniTest::Test
  include Aur::TagEdit

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
  end

  def test_mk_title_brackets_at_end
    assert_equal('Suburbia (The Full Horror)',
                 mk_title('suburbia-the_full_horror'))
  end

  def test_mk_title_brackets_in_middle
    assert_equal('This is (Almost) too Easy',
                 mk_title('this_is-almost-too_easy'))
  end

  def test_mk_title_initials
    assert_equal('C.R.E.E.P.', mk_title('c-r-e-e-p'))
    assert_equal('The N.W.R.A.', mk_title('the_n-w-r-a'))
    assert_equal('W.M.C. Blob 59', mk_title('w-m-c_blob_59'))
  end
end

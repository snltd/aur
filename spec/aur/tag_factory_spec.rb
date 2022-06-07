#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/aur/tag_factory'

# Ensure tags are generated correctly
#
class TestName2Tag < MiniTest::Test
  attr_reader :t

  def setup
    @t = Aur::TagFactory.new
  end

  def test_title_plain
    assert_equal('Blue Bell Knoll', t.title('blue_bell_knoll'))
  end

  def test_title_the
    assert_equal('The Boy with the Arab Strap',
                 t.title('the_boy_with_the_arab_strap'))
  end

  def test_title_last_word_preposition
    assert_equal('I Want to Wake Up', t.title('i_want_to_wake_up'))
  end

  def test_title_contraction
    assert_equal("Don't Go", t.title('dont_go'))
    assert_equal("You Can't Hold What You Haven't Got in Your Hand",
                 t.title('you_cant_hold_what_you_havent_got_in_your_hand'))
  end

  def test_title_brackets_at_end
    assert_equal('Suburbia (The Full Horror)',
                 t.title('suburbia-the_full_horror'))
    assert_equal('Om Mani Padme Hum 3 (Piano Version)',
                 t.title('om_mani_padme_hum_3-piano_version'))
    assert_equal('Drumming (Part III)', t.title('drumming-part_iii'))
  end

  def test_title_inches
    assert_equal('I Feel Love (12" Mix)', t.title('i_feel_love-12inch_mix'))
    assert_equal('Fugitive (7" Mix)', t.title('fugitive-7inch_mix'))
  end

  def test_title_long_dash
    assert_equal('When-Never', t.title('when--never'))
    assert_equal('Who-What and Maybe-Not',
                 t.title('who--what_and_maybe--not'))
    assert_equal('Tick-Tock-Tick-Tock',
                 t.title('tick--tock--tick--tock'))
  end

  def test_title_brackets_in_middle
    assert_equal('This Is (Almost) Too Easy',
                 t.title('this_is-almost-too_easy'))
    assert_equal('Can We Make It (Just a Little Bit) Harder',
                 t.title('can_we_make_it-just_a_little_bit-harder'))
    assert_equal('Title Ending In (Bracketed Words)',
                 t.title('title_ending_in-bracketed_words'))
    assert_equal('The (I.N.I.T.I.A.L.S.) In Brackets',
                 t.title('the-i-n-i-t-i-a-l-s-in_brackets'))
    assert_equal('Two (Lots) Of Brackets (Is Tricky)',
                 t.title('two-lots-of_brackets-is_tricky'))
    assert_equal('Variations 3 (Canon on the Unison)',
                 t.title('variations_3-canon_on_the_unison'))
  end

  def test_title_initials
    assert_equal('C.R.E.E.P.', t.title('c-r-e-e-p'))
    assert_equal('The N.W.R.A.', t.title('the_n-w-r-a'))
    assert_equal('W.M.C. Blob 59', t.title('w-m-c_blob_59'))
  end

  def test_artist
    assert_equal('Stereolab', t.artist('stereolab'))
    assert_equal('Royal Trux', t.artist('royal_trux'))
    assert_equal('Jeffrey Lewis and The Bolts',
                 t.artist('jeffrey_lewis_and_the_bolts'))
    assert_equal('Someone featuring Someone Else',
                 t.artist('someone_ft_someone_else'))
    assert_equal('R.E.M.', t.artist('r-e-m'))
    assert_equal('M.J. Hibbett', t.artist('m-j_hibbett'))
    assert_equal('ABBA', t.artist('abba'))
    assert_equal('Add N to (X)', t.artist('add_n_to_x'))
  end

  def test_album
    assert_equal('Spiderland', t.album('spiderland'))
    assert_equal('Mars Audiac Quintet', t.album('mars_audiac_quintet'))
    assert_equal('The Decline and Fall of Heavenly',
                 t.album('the_decline_and_fall_of_heavenly'))
  end

  def test_genre
    assert_equal('Noise', t.genre('noise'))
    assert_equal('Noise', t.genre('Noise '))
    assert_equal('Hip-Hop', t.genre('Hip-Hop'))
    assert_equal('Rock and Roll', t.genre('rock AND roll'))
  end

  def test_t_num
    assert_equal('1', t.t_num('01'))
    assert_equal('39', t.t_num('39'))
  end
end

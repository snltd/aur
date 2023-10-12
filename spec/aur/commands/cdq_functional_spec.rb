#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require_relative '../../spec_helper'
require_relative '../../../lib/aur/action'
require_relative '../../../lib/aur/fileinfo'

# Run 'aur cdq' commands against a real file, and verify the results
#
class TestCdqCommand < Minitest::Test
  parallelize_me!

  def test_hi_res_flac_to_cdq
    with_test_file('cdq') do |f|
      file = f.join('artist.hi-res.flac')

      original_tags = Aur::FileInfo.new(file).our_tags
      assert_equal('24-bit/96000Hz', Aur::FileInfo.new(file).bitrate)

      assert_output("#{file} -> #{file} [re-encoded]\n") do
        Aur::Action.new(:cdq, [file]).run!
      end

      assert_equal('16-bit/44100Hz', Aur::FileInfo.new(file).bitrate)
      new_tags = Aur::FileInfo.new(file).our_tags

      assert_equal(new_tags, original_tags)
    end
  end

  def test_cdq_no_need
    with_test_file('cdq') do |f|
      file = f.join('artist.already-cdq.flac')
      original_digest = Digest::MD5.file(file).hexdigest

      assert_output("File is already CD quality.\n") do
        Aur::Action.new(:cdq, [file]).run!
      end

      assert_equal(original_digest, Digest::MD5.file(file).hexdigest)
    end
  end

  def test_cdq_mp3
    with_test_file('cdq') do |f|
      file = f.join('artist.not-a-flac.mp3')

      original_digest = Digest::MD5.file(file).hexdigest

      assert_output("Can't convert lossy to lossless.\n") do
        Aur::Action.new(:cdq, [file]).run!
      end

      assert_equal(original_digest, Digest::MD5.file(file).hexdigest)
    end
  end
end

# frozen_string_literal: true

module Aur
  #
  # These commands can and should be run against all commands, by including
  # the module in the test class.
  #
  module CommandTests
    def test_bad_flac_info
      out, err = capture_io { Aur::Action.new(action, [BAD_FLAC]).run! }
      assert_empty(out)
      assert_equal("ERROR: cannot process '#{BAD_FLAC}'.\n", err)
    end

    def test_bad_mp3_info
      out, err = capture_io { Aur::Action.new(action, [BAD_MP3]).run! }
      assert_empty(out)
      assert_equal("ERROR: cannot process '#{BAD_MP3}'.\n", err)
    end

    def test_both_bad_files
      out, err = capture_io do
        Aur::Action.new(action, [BAD_FLAC, BAD_MP3]).run!
      end

      assert_empty(out)
      assert_equal(
        "ERROR: cannot process '#{BAD_FLAC}'.\n" \
        "ERROR: cannot process '#{BAD_MP3}'.\n",
        err
      )
    end
  end
end

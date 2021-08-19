# frozen_string_literal: true

module Aur
  #
  # These commands can and should be run against all commands, by including
  # the module in the test class.
  #
  module CommandTests
    def test_bad_flac_info
      assert_output(
        '',
        "ERROR: cannot process '#{RES_DIR + 'not_really_a.flac'}'.\n"
      ) do
        Aur::Action.new(action, [RES_DIR + 'not_really_a.flac']).run!
      end
    end

    def test_bad_mp3_info
      assert_output(
        '',
        "ERROR: cannot process '#{RES_DIR + 'not_really_a.mp3'}'.\n"
      ) do
        Aur::Action.new(action, [RES_DIR + 'not_really_a.mp3']).run!
      end
    end

    def test_both_bad_files
      assert_output(
        '',
        "ERROR: cannot process '#{RES_DIR + 'not_really_a.flac'}'.\n" \
        "ERROR: cannot process '#{RES_DIR + 'not_really_a.mp3'}'.\n"
      ) do
        Aur::Action.new(action, [RES_DIR + 'not_really_a.flac',
                                 RES_DIR + 'not_really_a.mp3']).run!
      end
    end
  end
end

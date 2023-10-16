# frozen_string_literal: true

module Aur
  #
  # These commands can and should be run against all commands, by including
  # the module in the test class.
  #
  module CommandTests
    def test_bad_flac_info
      assert_output('', "ERROR: cannot process '#{bad(:flac)}'.\n") do
        Aur::Action.new(action, [bad(:flac)]).run!
      end
    end

    def _test_bad_mp3_info
      assert_output('', "ERROR: cannot process '#{bad(:mp3)}'.\n") do
        Aur::Action.new(action, [bad(:mp3)]).run!
      end
    end

    def _test_both_bad_files
      assert_output('',
                    "ERROR: cannot process '#{bad(:flac)}'.\n" \
                    "ERROR: cannot process '#{bad(:mp3)}'.\n") do
        Aur::Action.new(action, [bad(:flac), bad(:mp3)]).run!
      end
    end

    def bad(suffix)
      RES_DIR.join('commands', 'common', "not_really_a.#{suffix}")
    end
  end
end

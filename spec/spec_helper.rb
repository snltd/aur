# frozen_string_literal: true

require 'colorize'
require 'pathname'
require 'minitest/autorun'
require 'spy/integration'
require_relative 'common_command_tests'
require_relative '../lib/aur/fileinfo'

RES_DIR = Pathname.new(__dir__) + 'resources'
TMP_DIR = Pathname.new('/tmp/aurtest')

TW = 70

String.disable_colorization true

TestTags = Struct.new(:artist,
                      :title,
                      :album,
                      :t_num,
                      :filetype,
                      keyword_init: true)

def setup_test_dir
  FileUtils.rm_r(TMP_DIR) if TMP_DIR.exist?
  FileUtils.mkdir_p(TMP_DIR)
end

def cleanup_test_dir
  FileUtils.rm_r(TMP_DIR) if TMP_DIR.exist?
end

# set up a test directory and put a copy of the given file inside it. Said
# file must be in RES_DIR.
# @param [String] name of file you wish to test
# @return [Pathname] reference to the file in TMP_DIR
#
def with_test_file(file)
  setup_test_dir
  FileUtils.cp_r(RES_DIR + file, TMP_DIR)
  file = file.basename if file.is_a?(Pathname)
  yield(TMP_DIR + file)
  cleanup_test_dir
end

# Nicked from StackOverflow, makes it easy to test things which require user
# input.
#
def with_stdin
  stdin = $stdin
  $stdin, write = IO.pipe
  yield write
ensure
  write.close
  $stdin = stdin
end

# Assert that the given file has the given tag.
#
def assert_tag(file, key, value)
  info = Aur::FileInfo.new(file)
  assert_equal(value.to_s, info.our_tags[key].to_s)
end

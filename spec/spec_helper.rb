# frozen_string_literal: true

require 'pathname'
require 'minitest/autorun'
require 'spy/integration'

RES_DIR = Pathname.new(__dir__) + 'resources'
TMP_DIR = Pathname.new('/tmp/aurtest')

FLAC_TEST = RES_DIR + 'test_tone-100hz.flac'
MP3_TEST = RES_DIR + 'test_tone-100hz.mp3'

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
def with_test_file(file)
  setup_test_dir
  FileUtils.cp(RES_DIR + file, TMP_DIR)
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
  info = if file.extname == '.flac'
           Aur::FileInfo::Flac.new(file)
         else
           Aur::FileInfo::Mp3.new(file)
         end

  assert_equal(value, info.our_tags[key])
end

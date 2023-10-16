# frozen_string_literal: true

require 'colorize'
require 'pathname'
require 'minitest/autorun'
require 'yaml'
require_relative 'common_command_tests'
require_relative '../lib/aur/fileinfo'

RES_DIR = Pathname.new(__dir__).join('resources')

TW = 70

String.disable_colorization true

TestTags = Struct.new(:artist,
                      :title,
                      :album,
                      :t_num,
                      :filetype,
                      keyword_init: true)

# Set up a test directory and put a copy of the given file inside it. Said
# file must be in RES_DIR.
# @param [String] name of file you wish to test
# @return [Pathname] reference to the file in temp directory
#
def with_test_file(file)
  Dir.mktmpdir do |dir|
    dir = Pathname.new(dir)
    FileUtils.cp_r(RES_DIR.join(file), dir)
    file = file.basename if file.is_a?(Pathname)
    yield(dir.join(file))
  end
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

CONF = YAML.safe_load(
  %(
tagging:
  no_caps:
    - a
    - and
    - featuring
    - for
    - in
    - is
    - it
    - of
    - 'on'
    - or
    - that
    - the
    - to
    - with
  all_caps:
    - abba
    - ep
    - ii
    - lp
    - ok
  expand:
    add_n_to_x: "Add N to (X)"
), symbolize_names: true
).freeze

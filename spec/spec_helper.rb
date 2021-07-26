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

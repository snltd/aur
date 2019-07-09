# frozen_string_literal: true

require 'pathname'
require 'minitest/autorun'
require 'spy/integration'

RES_DIR = Pathname.new(__dir__) + 'resources'

FLAC_TEST = RES_DIR + 'test_tone-100hz.flac'
MP3_TEST = RES_DIR + 'test_tone-100hz.mp3'

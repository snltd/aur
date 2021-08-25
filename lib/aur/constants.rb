# frozen_string_literal: true

require 'pathname'

SUPPORTED_TYPES = %w[flac mp3].freeze

BIN = {
  ffmpeg: Pathname.new('/opt/sysdef/ffmpeg/bin/ffmpeg'),
  flac: Pathname.new('/opt/local/bin/flac'),
  lame: Pathname.new('/opt/local/bin/lame'),
  metaflac: Pathname.new('/opt/local/bin/metaflac'),
  shnsplit: Pathname.new('/opt/local/bin/shnsplit')
}.freeze

# Preset for encoding MP3s
#
LAME_FLAGS = '-h --vbr-new --preset 128 --id3v2-only --add-id3v2 --silent'

# These words are not (normally) capitalised when generating tags. 'featuring'
# is there for artist names.
#
NO_CAPS = %w[a an and are as as at By de featuring for from in is into la
             le nor of off on onto or out per so than that the till to
             too via vs when with].freeze

# The keys of this hash are expanded to the corresponding value when
# generating tags. Some of these contractions are, of course, real words, but
# you're more likely to see can't than cant and won't than wont. Lets and its
# are less certain, but I think they're more commonly expanded than not.
#
EXPAND = {
  '12inch': '12"',
  '7inch': '7"',
  '--': ' - ',
  '&': 'and',
  aint: "ain't",
  cant: "can't",
  couldnt: "couldn't",
  didnt: "didn't",
  doesnt: "doesn't",
  dont: "don't",
  etc: 'etc.',
  ft: 'featuring',
  hes: "he's",
  havent: "haven't",
  ii: 'II',
  iii: 'III',
  iv: 'IV',
  ive: "I've",
  im: "I'm",
  isnt: "isn't",
  its: "it's",
  lets: "let's",
  n: "'n'",
  shes: "she's",
  thats: "that's",
  theres: "there's",
  wasnt: "wasn't",
  weve: "we've",
  whos: "who's",
  wont: "won't",
  wouldnt: "wouldn't",
  youll: "you'll",
  youre: "you're",
  youve: "you've"
}.freeze

# These are the tags we wish a file to have.
#
REQ_TAGS = {
  flac: %i[album artist block_size date genre offset title tracknumber
           vendor_tag],
  mp3: %i[talb tcon tit2 tpe1 trck tyer]
}.freeze

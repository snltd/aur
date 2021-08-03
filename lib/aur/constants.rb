# frozen_string_literal: true

SUPPORTED_TYPES = %w[flac mp3].freeze

BIN = {
  ffmpeg: Pathname.new('/opt/sysdef/ffmpeg/bin/ffmpeg'),
  flac: Pathname.new('/opt/local/bin/flac'),
  lame: Pathname.new('/opt/local/bin/lame'),
  shnsplit: Pathname.new('/opt/local/bin/shnsplit')
}.freeze

# Preset for encoding MP3s
#
LAME_FLAGS = '-h --vbr-new --preset 128 --id3v2-only --add-id3v2 --silent'

# These words are not (normally) capitalised when generating tags
#
NO_CAPS = %w[a aboard about above absent across after against along
             alongside amid amidst among amongst an and around as as
             aslant astride at athwart atop barring before behind
             below beneath beside besides between beyond but by
             despite down during except failing following for for
             from in is inside into like mid minus near next nor
             notwithstanding of off on onto opposite or out outside
             over past per plus regarding round save since so than
             the through throughout till times to too toward towards
             under underneath unlike until up upon via vs when with
             within without worth yet].freeze

# The keys of this hash are expanded to the corresponding value when
# generating tags. Some of these contractions are, of course, real words, but
# you're more likely to see can't than cant and won't than wont. Lets and its
# are less certain, but I think they're more commonly expanded than not.
#
EXPAND = {
  '&': 'and',
  aint: "ain't",
  cant: "can't",
  couldnt: "couldn't",
  didnt: "didn't",
  dont: "don't",
  etc: 'etc.',
  hes: "he's",
  havent: "haven't",
  im: "I'm",
  isnt: "isn't",
  its: "it's",
  lets: "let's",
  n: "'n'",
  shes: "she's",
  thats: "that's",
  theres: "there's",
  weve: "we've",
  whos: "who's",
  wont: "won't",
  wouldnt: "wouldn't",
  youll: "you'll",
  youre: "you're",
  youve: "you've"
}.freeze

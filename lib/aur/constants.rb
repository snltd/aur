# frozen_string_literal: true

SUPPORTED_TYPES = %w[flac mp3].freeze

BIN = { flac: Pathname.new('/usr/bin/flac'),
        shnsplit: Pathname.new('/usr/bin/shnsplit') }.freeze

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
# generating tags
#
EXPAND = {
  '&': 'and',
  cant: "can't",
  couldnt: "couldn't",
  etc: 'etc.',
  hes: "he's",
  im: "I'm",
  its: "it's",
  shes: "she's",
  thats: "that's",
  theres: "there's",
  weve: "we've",
  wont: "won't",
  wouldnt: "wouldn't",
  youll: "you'll",
  youre: "you're",
  youve: "you've",
  dont: "don't"
}.freeze

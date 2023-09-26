# frozen_string_literal: true

require 'pathname'

DATA_DIR = Pathname.new('/storage')
BIN_DIRS = Pathname.new('/opt/ooce/bin')

BIN_DIR = if BIN_DIRS.exist?
            BIN_DIRS
          else
            Pathname.new('/usr/bin')
          end

SUPPORTED_TYPES = %w[flac mp3].freeze

BIN = %i[ffmpeg flac lame metaflac shnsplit convert].to_h do |f|
  [f, BIN_DIR.join(f.to_s)]
end

# We convert FLACs to this MP3 bitrate, and flag up MP3s which are higher
#
MP3_BITRATE = 128

# Preset for encoding MP3s
#
LAME_FLAGS = "-q2 --vbr-new --preset #{MP3_BITRATE} --id3v2-only " \
             '--add-id3v2 --silent'.freeze

# Preset for dithering "hi-res" files to CD quality. Which is plenty.
#
CDQ_FFMPEG_FLAGS = '-af aresample=out_sample_fmt=s16:out_sample_rate=44100'

# The keys of this hash are expanded to the corresponding value when
# generating tags. Some of these contractions are, of course, real words, but
# you're more likely to see can't than cant and won't than wont. Lets and its
# are less certain, but I think they're more commonly expanded than not.
#
TAGGING = {
  all_caps: %w[
    cd
    diy
    dvd
    ep
    ii
    iii
    iv
    ix
    lp
    ok
    ps
    uk
    usa
    vi
    vii
    viii
    xi
    xii
    xiii
    xiv
    xv
    xvi
    xviii
    xxi
    xxv
    xxx
  ],
  no_caps: %w[
    a
    am
    an
    and
    are
    as
    at
    au
    by
    ce
    dans
    de
    des
    du
    es
    est
    et
    featuring
    for
    from
    in
    into
    is
    isnt
    it
    its
    la
    le
    ne
    nor
    o'clock
    of
    off
    on
    onto
    or
    out
    pas
    per
    se
    so
    te
    than
    that
    the
    till
    to
    too
    un
    une
    via
    vs
    when
    with
  ],
  expand: {
    '12inch': '12"',
    '7inch': '7"',
    '--': ' - ',
    '&': 'and',
    aint: "ain't",
    cant: "can't",
    couldnt: "couldn't",
    didnt: "didn't",
    dj: 'DJ',
    doesnt: "doesn't",
    dont: "don't",
    etc: 'etc.',
    ft: 'featuring',
    hes: "he's",
    havent: "haven't",
    ii: 'II',
    iii: 'III',
    iv: 'IV',
    ix: 'IX',
    ive: "I've",
    im: "I'm",
    isnt: "isn't",
    its: "it's",
    lets: "let's",
    n: "'n'",
    shes: "she's",
    thats: "that's",
    theres: "there's",
    v: 'V',
    vi: 'VI',
    vii: 'VII',
    wasnt: "wasn't",
    weve: "we've",
    whos: "who's",
    wont: "won't",
    wouldnt: "wouldn't",
    x: 'X',
    xi: 'XI',
    xii: 'XII',
    youll: "you'll",
    youre: "you're",
    youve: "you've"
  },
  ignore_case: [
    'x'
  ]
}.freeze

# These are the tags we wish a file to have.
#
REQ_TAGS = {
  flac: %i[album artist block_size date genre offset title tracknumber
           vendor_tag],
  mp3: %i[talb tcon tit2 tpe1 trck tyer]
}.freeze

# Permissible dimensions of cover art. And dimensions must be square.
#
ARTWORK_DEF = 700 # default size
ARTWORK_MIN = 375 # but we will tolerate this
ARTWORK_DIR = Pathname.new(Dir.home).join('work', 'artfix')

# Site-specific stuff, where you can ignore errors.
#
CONF_FILE = Pathname.new(Dir.home).join('.aur.yml')

# Ratio of disk space to runtime of an album. Any more than this and re might
# re-encode
#
SPACE_RATIO = 140_000

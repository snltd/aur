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

# FFMPEG flags for dithering hi-res files to CD quality.
#
CDQ_FFMPEG_FLAGS = '-af aresample=out_sample_fmt=s16:out_sample_rate=44100'

# These words are not (normally) capitalised when generating tags. 'featuring'
# is there for artist names.
#
NO_CAPS = %w[a am an and are as as at by de featuring for from in is it into la
             le nor of off on onto or out per so than that the till to o'clock
             au ne pas es se ce its oclock kd lang bloweyelashwish
             lovesliescrushing case/lang/viers
             est dans isnt des te du un une et too via vs when with].freeze

# These words should always be fully upper-cased.
#
ALL_CAPS = %w[ok dj lp ep l.a. bmr bbc scsi ii iii iv vi vii ix xi cd fm tko
              xii viii xiii xiv diy pbm psb pm kvrx ckid ulc bt ufo 4ad jdp
              sm omd nyc mf cv tr sh jt gsg bbc2 qed isbn gsoh qed fb amc
              xv dlp xxv xviii xvi xxi hiv usa ost wiaiwya vv lsxx rm zz cvb
              kb gr gb uk mdma tvr17 tvc wmc emi tda vsx lcd kg uv jlh bs ts
              ww3 wr fbi vvv tx qwerty nw abc gq olv sm57 wkrp hp hc ox4 jc qrj
              dvd tnt acd csi xr3 acac 4ad3dcd vip kfc uvtv nme gf bf abba bmx
              fc 3cp a&r r&b ihop lsd lcd lp2 mbv pcp urc uk nato afx mj ac/dc
              jxl tm usm klf m/a/r/r/s mc5 ps tv gtg bnoc nypd mtv od afx2
              kmfdm dc km
              ep lp pcm dva xxx isan krk npl mc brkn01 brkn02 brkn03].freeze

# These words should be ignored when examining case
#
IGNORE_CASE = %w[d'isan o'keefe mcgee mcintyre ça b's mccay mccoy lps eps mxbx
                 mccarthy d'or a: iiia iiib 5-6-7-8's v/vm mccartney mms
                 mcculloch hearts!attack mclusky
                 mcalmont mccarthy x tatu d'arby mccombs mcdonalds us].freeze

# These special cases can contain ampersands
#
ALLOWABLE_AMPERSANDS = ['The A&R EP', 'The R&B of Membership', '7 & 7'].freeze

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

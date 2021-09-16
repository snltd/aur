# Aur
[![Test](https://github.com/snltd/aur/actions/workflows/test.yml/badge.svg)](https://github.com/snltd/aur/actions/workflows/test.yml) [![Release](https://github.com/snltd/aur/actions/workflows/release.yml/badge.svg)](https://github.com/snltd/aur/actions/workflows/release.yml)

I have a pretty large collection of digital music (and even bigger physical
one) and I like to keep it organized. *Really* organized.

This program helps with that, pulling together a dozen or so smaller scripts
written over the last twenty-ish years in various language, adding tests and a
uniform interface.

Rules and assumptions are:

* FLACs are in `/storage/flac`; MP3s are in `/storage/mp3`. Every FLAC exists
  as an MP3, but not vice-versa.
* Albums are under `albums/abc` etc; EPs and singles under `eps/`; loose
  tracks under `tracks`. Stuff to be processed and filed is under `new/`.
* Audio files are named `nn.artist.title.suffix`. nn is a zero-padded
  two-digit number. If the artist is "The" something, `the_` is removed from
  the start of the filename.
* Tags must be populated for artist, title, album, track number, genre and
  year. Any other tags are removed.
* FLAC albums have artwork stored as `front.jpg` or `front.png`. MP3s have no
  artwork. Embedded artwork is removed.
* Capitalisation of titles is broadly in line with
  [this](https://www.ox.ac.uk/sites/files/oxford/Style%20Guide%20HT2016.pdf)
* Loads of other finnicky little nitpicks peculiar to me.

This program will likely be of no use to anyone else in the world, but I use
it all the time.

There are thousands of alternatives which do not implement all my personal
preferences. Use one of those.

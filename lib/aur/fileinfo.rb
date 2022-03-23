# frozen_string_literal: true

require 'flacinfo'
require 'mp3info'
require_relative 'exception'
require_relative 'constants'
require_relative 'stdlib/pathname'

module Aur
  #
  # FileInfo gives you access to lots of information about a file,
  # abstracting each supported filetype to a common interface.
  #
  class FileInfo
    attr_reader :file, :info, :raw, :opts

    # We don't currently use opts. Here for consistency.
    #
    def initialize(file, opts = {})
      load_specifics(file)
      @file = file
      @info = @raw = read
      @opts = opts
      post_initialize if respond_to?(:post_initialize)
    end

    def bitrate
      format('%<bits>s-bit/%<rate>sHz',
             bits: info.streaminfo['bits_per_sample'],
             rate: info.streaminfo['samplerate'])
    end

    def tags
      flatten_keys(info.tags)
    end

    def filetype
      file.extname.to_s.delete('.').downcase
    end

    # @return [String] a name that will fit in a given width
    #
    def prt_name(max = 60)
      raw = file.basename.to_s

      return raw if raw.length <= max

      raw[0..(max - 4)] + '...'
    end

    # The f_ methods assume a file has a dot-separated name
    #
    def f_artist
      fname_bits[-3] || 'unknown_artist'
    end

    def f_album
      file.dirname.expand_path.basename.to_s.split('.', 2).last
    end

    def f_title
      fname_bits[-2]
    end

    def f_t_num
      /^\d\d?/.match?(fname_bits.first) ? fname_bits.first : '00'
    end

    def tag_for(field)
      tag_map.fetch(field, nil)
    end

    def tag_name(field)
      tag_names.fetch(field, nil)
    end

    # return [Hash] just the tags we use in our names and infos
    def our_tags
      tag_map.tap do |t|
        t.each_pair { |k, v| t[k] = tags.fetch(v, nil) }
      end
    end

    def required_tags
      REQ_TAGS[filetype.to_sym]
    end

    # @return [Bool] whether the tags we see are the tags we expect
    #
    def incorrect_tags?
      tags.keys.map(&:to_sym).sort != required_tags.sort
    end

    private

    def load_specifics(file)
      case file.extname.downcase
      when '.flac'
        extend Aur::FileInfoFlac
      when '.mp3'
        extend Aur::FileInfoMp3
      else
        raise Aur::Exception::UnsupportedFiletype
      end
    end

    # @return [Array] dot-separated filename segments
    #
    def fname_bits
      file.basename.to_s.split('.')
    end

    # There's no guarantee that even if we have the right keys in
    # the tag hash, they will have the right case. So make
    # everything a lower-case symbol
    #
    def flatten_keys(hash)
      hash.transform_keys(&:downcase).transform_keys(&:to_sym)
    end

    # To access tags can use a method with the name of the tag. This works
    # by looking up the method name in tag_map and returning the tag with
    # that key. If there's no such key in the tag map, chuck it up to the
    # superclass.
    #
    def method_missing(method, *_args)
      return tags[tag_map[method]] if tag_map.key?(method)

      super
    end

    def respond_to_missing?(method, *_args)
      tag_map.key?(method) || super
    end
  end

  # Methods specific to FLACs
  #
  module FileInfoFlac
    def read
      FlacInfo.new(file)
    end

    # This hash maps our common tag names to the names the FLAC library
    # uses, presenting a consistent interface. There's one like it in the
    # MP3 class.
    #
    def tag_map
      { artist: :artist,
        album: :album,
        title: :title,
        t_num: :tracknumber,
        year: :date,
        genre: :genre }
    end

    # This hash maps what we call tags to the names we have to pass to the
    # tagging library to manipulate them.
    #
    def tag_names
      { artist: 'ARTIST',
        album: 'ALBUM',
        title: 'TITLE',
        t_num: 'TRACKNUMBER',
        year: 'DATE',
        genre: 'GENRE' }
    end

    # @return [Bool] whether there's an embedded image
    #
    def picture?
      info.picture['n'].positive?
    end

    def partner(this_file = file)
      this_file.expand_path.sub(%r{/flac/}, '/mp3/').sub_ext('.mp3')
    end
  end

  # Methods specific to MP3s. We are all about id3v2. v1 is nowhere.
  #
  module FileInfoMp3
    def read
      Mp3Info.open(file)
    end

    def bitrate
      format('%<rate>skbps%<extra>s',
             rate: info.bitrate,
             extra: info.vbr ? ' (variable)' : '')
    end

    def tags
      flatten_keys(info.tag2)
    end

    def tag_map
      { artist: :tpe1,
        album: :talb,
        title: :tit2,
        t_num: :trck,
        year: :tyer,
        genre: :tcon }
    end

    def tag_names
      { artist: 'TPE1',
        album: 'TALB',
        title: 'TIT2',
        t_num: 'TRCK',
        year: 'TYER',
        genre: 'TCON' }
    end

    def picture?
      !info.tag2.pictures.empty?
    end

    def partner(this_file = file)
      this_file.expand_path.sub(%r{/mp3/}, '/flac/').sub_ext('.flac')
    end
  end
end

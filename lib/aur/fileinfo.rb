# frozen_string_literal: true

require_relative 'stdlib/pathname'
require 'flacinfo'
require 'mp3info'

module Aur
  module FileInfo
    #
    # Methods to deal with FLACs
    #
    class Flac
      attr_reader :file, :info, :raw

      def initialize(file)
        @file = file
        @info = @raw = read
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
        self.class.name.split('::').last.downcase
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
        file.dirname.realpath.basename.to_s
      end

      def f_title
        fname_bits[-2]
      end

      def f_t_num
        fname_bits.first =~ /^\d\d?/ ? fname_bits.first : '00'
      end

      def tag_for(field)
        tag_map.fetch(field, nil)
      end

      private

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

      def read
        FlacInfo.new(file)
      end

      def method_missing(method, *_args)
        return tags[tag_map[method]] if tag_map.key?(method)

        super
      end

      def respond_to_missing?(method, *_args)
        tag_map.key?(method) || super
      end

      # This hash, and one like it in the MP3 class, lets us refer
      # to FLACs and MP3s in the same general way.
      #
      def tag_map
        { artist: :artist,
          album:  :album,
          title:  :title,
          t_num:  :tracknumber,
          year:   :date,
          genre:  :genre }
      end
    end

    #
    # Methods to deal with MP3s
    #
    class Mp3 < Flac
      def read
        Mp3Info.open(file)
      end

      def bitrate
        format('%<rate>skbps%<extra>s',
               rate: info.bitrate,
               extra: info.vbr ? ' (variable)' : '')
      end

      def tags
        flatten_keys(info.tag)
      end

      private

      def tag_map
        { artist: :artist,
          album:  :album,
          title:  :title,
          t_num:  :tracknum,
          year:   :year,
          genre:  :genre }
      end
    end
  end
end

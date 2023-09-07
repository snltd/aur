# frozen_string_literal: true

require_relative '../constants'
require_relative '../fileinfo'
require_relative '../stdlib/string'
require_relative 'mixins/file_tree'
require 'set'

module Aur
  module Command
    #
    # Finds artists with similar, but not identical, names.
    #
    class Namecheck
      include Aur::Mixin::FileTree

      def initialize(dir = nil, _opts = {})
        @files = files(dir&.expand_path)
      end

      def run
        artist_list = unique_list_of_artists(@files)
        check_thes(artist_list)
        check_compacted(artist_list)
      end

      def files(dir)
        suffix = if dir.to_s.include?('/flac')
                   '.flac'
                 elsif dir.to_s.include?('/mp3')
                   '.mp3'
                 else
                   abort 'what is filetype?'
                 end

        files_under(dir, suffix).keys
      end

      def unique_list_of_artists(files)
        files.each_with_object({}) do |f, ret|
          info = Aur::FileInfo.new(f)

          ret[info.artist] = if ret.key?(info.artist)
                               ret[info.artist] << (f.dirname)
                             else
                               [f.dirname]
                             end
        end
      end

      def check_thes(artists)
        artists.select { |k, _v| k.start_with?('The ') }.each do |k, dir|
          no_the = k.sub('The ', '')
          output(k, dir, no_the, artists[no_the]) if artists.key?(no_the)
        end
      end

      def check_compacted(artists)
        seen = {}

        artists.each do |k, dir|
          cname = k.compacted

          if seen.key?(cname)
            output(k, dir, seen[cname][:prev_name], seen[cname][:dirs])
            seen[cname][:dirs] += dir.map(&:to_s)
          else
            seen[cname] = { dirs: dir.map(&:to_s), prev_name: k }
          end
        end
      end

      def self.screen_flist(_flist, opts)
        opts[:'<directory>'].to_paths
      end

      def output(name1, dirs1, name2, dirs2)
        puts name1
        dirs1.sort.uniq.each { |d| puts "  #{d}" }
        puts name2
        dirs2.sort.uniq.each { |d| puts "  #{d}" }
        puts
      end

      def self.help
        <<~EOHELP
          usage: aur namecheck

          Finds artists with similar, but not identical, names.

          Looks for missing "The"s, and removes all punctuation and
          capitalisation from names before looking for duplicates.

          Is recursive.
        EOHELP
      end
    end
  end
end

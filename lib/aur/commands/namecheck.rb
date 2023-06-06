# frozen_string_literal: true

require_relative '../constants'
require_relative '../fileinfo'
require_relative 'mixins/file_tree'
require 'set'

module Aur
  module Command
    #
    # Finds artists with similar, but not identical, names. I'm not certain
    # exactly how I want to define this
    #
    # Look at all the "The"s, and see if we also have the name without the
    # "The". This is an error.
    #
    class Namecheck
      include Aur::Mixin::FileTree

      def initialize(dir = nil, opts = {})
        @dir = dir&.expand_path
        @opts = opts
        @files = files(@dir)
      end

      def files(dir)
        if dir.to_s.include?('/flac')
          suffix = '.flac'
        elsif dir.to_s.include?('/mp3')
          suffix = '.mp3'
        else
          abort 'what is filetype?'
        end

        files_under(dir, suffix).keys
      end

      def run
        unique_artists = unique_list_of_artists(@files)
        check_thes(unique_artists)
      end

      def unique_list_of_artists(files)
        ret = {}

        files.each do |f|
          info = Aur::FileInfo.new(f)

          ret[info.artist] = if ret.key?(info.artist)
                               ret[info.artist] << (f.dirname)
                             else
                               [f.dirname]
                             end
        end

        ret
      end

      def check_thes(artists)
        thes = artists.select { |k, _v| k.start_with?('The ') }

        thes.each do |k, dir|
          without_the = k.sub('The ', '')

          if artists.key?(without_the)
            output(k, dir, without_the, artists[without_the])
          end
        end
      end

      def self.screen_flist(_flist, opts)
        dirs = opts[:'<directory>'].to_paths
        opts[:recursive] ? Aur::Helpers.recursive_dir_list(dirs) : dirs
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

          Looks for missing "The"s.
        EOHELP
      end
    end
  end
end

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

      def initialize(dir = nil, _opts = {})
        @files = files(dir&.expand_path)
      end

      def run
        check_thes(unique_list_of_artists(@files))
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

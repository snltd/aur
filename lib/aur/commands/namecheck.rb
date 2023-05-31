# frozen_string_literal: true

require_relative '../stdlib/pathname'
require_relative '../constants'
require_relative 'mixins/file_tree'

module Aur
  module Command
    #
    # Finds artists with similar, but not identical, names. I'm not certain
    # exactly how I want to define this
    #
    # Look at all the "The"s, and see if we also have the name without the
    # "The". This is an error.
    #
    #
    #
    class Namecheck
      include Aur::Mixin::FileTree

      def initialize(_root, opts = {})
        dir = Pathname.new(opts[:'<directory>'].first).expand_path

        if dir.to_s.include?('/flac')
          @files = files_under(dir, '.flac')
        elsif dir.to_s.include?('/mp3')
          @files = files_under(dir, '.flac')
        else
          abort 'what is filetype?'
        end
      end

      def run
        puts 'possible misnames'
        p @files
        #output(find_dupes(all_flacs))
      end

      #def output(dupes)
        #return '  none' if dupes.empty?
#
        #dupes.each do |track, matches|
          #puts track
          #puts(matches.map { |match| "  #{match}" })
          #puts
        #end
      #end

      def find_dupes(files)
        needles = files.select { |k, _| k.lastdir == 'tracks' }
        haystack = files.reject { |k, _v| k.dirname.basename.to_s == 'tracks' }

        procs = needles.transform_values do |name|
          haystack.select { |_k, v| v == name }.keys
        end

        procs.reject { |_k, v| v.empty? }
      end

      def all_flacs
        files_under(@fdir, '.flac')
      end

      def all_mp3s
        files_under(@mdir, '.mp3')
      end

      def self.screen_flist(_flist, _opts)
        [DATA_DIR]
      end

      def self.help
        <<~EOHELP
          usage: aur dupes

          Finds files in tracks/ which may be duplicates of tracks in the
          albums/ or eps/ directories. It does this very naively, and its output
          is only a recommendation for further investigation.
        EOHELP
      end
    end
  end
end

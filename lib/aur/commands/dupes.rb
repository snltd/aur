# frozen_string_literal: true

require_relative '../stdlib/pathname'
require_relative 'mixins/file_tree'

module Aur
  module Command
    #
    # Finds things in tracks/ that may exist elsewhere
    #
    class Dupes
      attr_reader :fdir, :mdir, :opts

      include Aur::Mixin::FileTree

      def initialize(root, opts = {})
        @opts = opts
        @fdir = root + 'flac'
        @mdir = root + 'mp3'
      end

      def run
        puts 'possible FLAC duplicates'
        output(find_dupes(all_flacs))
        puts "\npossible MP3 duplicates"
        output(find_dupes(all_mp3s))
      end

      def output(dupes)
        return '  none' if dupes.empty?

        dupes.each do |track, matches|
          puts track
          matches.each do |match|
            puts "  #{match}"
          end
          puts
        end
      end

      def find_dupes(files)
        needles = files.select { |k, _| k.lastdir == 'tracks' }
        haystack = files.reject { |k, _v| k.dirname.basename.to_s == 'tracks' }

        procs = needles.transform_values do |name|
          haystack.select { |_k, v| v == name }.keys
        end

        procs.reject { |_k, v| v.empty? }
      end

      def all_flacs
        files_under(fdir, '.flac')
      end

      def all_mp3s
        files_under(mdir, '.mp3')
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

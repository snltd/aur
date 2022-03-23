# frozen_string_literal: true

require 'colorize'
require 'fileutils'
require_relative 'base'
require_relative '../constants'
require_relative '../renamers'
require_relative 'mixins/flac2mp3'

module Aur
  module Command
    #
    # Transcodes directories of FLACs into directories of MP3s.
    #
    class Mp3dir
      include Aur::Renamers
      include Aur::Mixin::Flac2mp3

      attr_reader :dir, :opts, :source_dir, :target_dir

      def initialize(dir = nil, opts = {})
        check_dependencies
        @dir = dir
        @opts = opts
        @source_dir = dir.realpath
        @target_dir = mp3_target_dir(source_dir)
        safety_check
      end

      def safety_check
        return true if source_dir.to_s.split('/').include?('flac')

        raise Aur::Exception::InvalidInput,
              "#{source_dir} is not in /flac/ hierarchy"
      end

      def run
        setup

        flacs_in(dir).each do |source|
          dest = target_file(source)
          next if dest.exist? && !opts[:force]

          transcode(source, dest)
        end

        cleanup
      end

      def setup
        FileUtils.mkdir_p(target_dir)
        puts source_dir.to_s.bold
      end

      def cleanup
        remove_leftovers(source_dir, target_dir)
      end

      def target_file(source)
        target_dir + source.basename.sub_ext('.mp3')
      end

      def flacs_in(dir)
        dir.children.select { |f| f.extname == '.flac' }.sort
      end

      def mp3_target_dir(source_dir)
        source_dir.sub(%r{/flac/}, '/mp3/')
      end

      def transcode(source, dest)
        info = Aur::FileInfo.new(source)
        cmd = construct_command(source, dest, info.our_tags)
        puts "  -> #{dest.basename}"
        system(cmd)
      end

      # Removes any MP3s (in dest) that don't have FLAC equivalents (in
      # source). Doesn't remove anything in tracks/ directories.
      #
      def remove_leftovers(source, dest)
        return if dest.basename.to_s == 'tracks'

        dest.children.select(&:file?).each do |mp3|
          flac = source + mp3.basename.sub_ext('.flac')

          next if flac.exist?

          puts "  removing #{mp3}"
          mp3.unlink
        end
      end

      def self.screen_flist(_flist, opts)
        opts[:'<directory>'].to_paths
      end

      def self.help
        <<~EOHELP
          usage: aur mp3dir [-rf] <directory>...

          Converts a directory full of FLACs into a directory of MP3s using
          the same LAME presets as flac2mp3.

          The target directory is at the same place in the MP3 hierarchy as
          the source is in the FLAC one.
        EOHELP
      end
    end
  end
end

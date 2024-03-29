# frozen_string_literal: true

require 'mp3info'
require_relative 'base'

module Aur
  module Command
    #
    # Promotes ID3v1 tags to ID3v2 tags if the former are all a file has.
    # ID3v1 is an absolute shower, and getting tags is pot-luck. This makes a
    # best-guess effort that is deemed to "do".
    #
    class Copytags < Base
      attr_reader :partner

      def run
        @partner = info.partner
        copy_tags if @partner.exist? && needs_retagging?(info.our_tags)
      rescue Encoding::CompatibilityError
        puts "Bad encoding on #{file}"
      end

      def needs_retagging?(tags)
        return true if opts[:force]

        return true if opts[:forcemod] && partner.mtime > file.mtime

        tags_of_interest = tags
        tags_of_interest.delete(:album) if file.expand_path.lastdir == 'tracks'
        tags_of_interest.values.any?(&:nil?)
      end

      def copy_tags
        puts 'copying tags from flac'
        tagger.tag!(Aur::FileInfo.new(@partner).our_tags)
      end

      def self.screen_flist(flist, opts)
        raw_list = flist.flat_map do |f|
          if f.directory? && opts[:recursive]
            Pathname.glob("#{f}/**/*")
          else
            f
          end
        end

        raw_list.uniq.select do |f|
          f.file? && SUPPORTED_TYPES.include?(f.extname.delete('.'))
        end
      end

      def self.help
        <<~EOHELP
          usage: aur copytags [-r] <file>...

          Operates on an MP3 file, copying the tags from the corresponding
          FLAC, if one exists.
        EOHELP
      end
    end
  end
end

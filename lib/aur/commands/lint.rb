# frozen_string_literal: true

require 'pathname'
require_relative '../carer'
require_relative '../fileinfo'
require_relative '../constants'
require_relative '../exception'
require_relative '../tag_validator'
require_relative '../stdlib/string'

module Aur
  module Command
    #
    # Examines files and compares them with our standards.
    #
    # rubocop:disable Metrics/ClassLength
    class Lint
      attr_reader :file, :info, :opts, :validator

      def initialize(file = nil, opts = {})
        @file = file
        extend Aur::Command::LintTracks if in_tracks?
        @info = Aur::FileInfo.new(file)
        @opts = opts
        extend Aur::Command::LintMp3 if @info.mp3?
        @validator = Aur::TagValidator.new(info, opts)
        @carer = Aur::Carer.new(CONF)
      end

      def run
        lint(@file)
      rescue Errno::ENOENT
        warn "'#{@file}' not found."
        false
      end

      # rubocop:disable Metrics/MethodLength
      def lint(file)
        correctly_named?(file)
        correct_tags?
        correct_tag_values?
        no_byte_order?
        reasonable_bitrate? if respond_to?(:reasonable_bitrate?)
      rescue Aur::Exception::LintBadName => e
        err(e, file, 'Invalid file name')
      rescue Aur::Exception::LintMissingTags => e
        err(e, file, "Missing tags: #{e}")
      rescue Aur::Exception::LintUnwantedTags => e
        err(e, file, "Unwanted tags: #{e}")
      rescue Aur::Exception::InvalidTagValue => e
        err(e, file, "Invalid tag value: #{e}")
      rescue Aur::Exception::LintDuplicateTags => e
        err(e, file, "Duplicate tags: #{e}")
      rescue Aur::Exception::LintHighBitrateMp3 => e
        err(e, file, "High MP3 bitrate: #{e}")
      rescue Aur::Exception::LintHasByteOrder => e
        err(e, file, "Tag has byte order char: #{e}")
      end
      # rubocop:enable Metrics/MethodLength

      def err(exception, file, msg)
        return if @carer.do_we?(exception, file)

        if opts[:summary]
          raise Aur::Exception::Collector, "#{file.dirname}: #{msg}"
        end

        warn(format('%-110<file>s    %<msg>s', file: file, msg: msg))
      end

      # A "proper" file name should be of the form
      # 'track_number.artist_name.title.suffix'.
      #
      def correctly_named?(file)
        chunks = file.basename.to_s.split('.')

        return true if name_checks_out?(chunks)

        raise Aur::Exception::LintBadName
      end

      def no_byte_order?
        info.our_tags.compact.each do |tag, val|
          raise Aur::Exception::LintHasByteOrder, tag if val.bom?
        end
      end

      # Do we have the tags we expect to have? For now, at least, we're not
      # going to worry about additional tags.
      #
      def correct_tags?
        missing_tags?
        unwanted_tags?
        duplicate_tags?
      end

      def missing_tags?
        missing_tags = required_tags - info.tags.keys - optional_tags
        return true if missing_tags.empty?

        raise Aur::Exception::LintMissingTags, missing_tags.join(', ')
      end

      def unwanted_tags?
        unwanted_tags = info.tags.keys - required_tags - optional_tags
        return true if unwanted_tags.empty?

        raise Aur::Exception::LintUnwantedTags, unwanted_tags.join(', ')
      end

      def duplicate_tags?
        tag_keys = info.rawtags.keys

        return true if tag_keys.count == tag_keys.map(&:downcase).uniq.count

        raise Aur::Exception::LintDuplicateTags
      end

      # Are tags (reasonably) correctly populated?
      #
      def correct_tag_values?
        validate_tags(info.our_tags)
        validate_album_disc(info.album, file.dirname.basename.to_s)
      end

      # If a file is in a disc_n directory, does it have an appropriate album
      # tag? And if it has an album tag denoting a particular disc, is it in a
      # disc_n directory?
      #
      def validate_album_disc(album_tag, file_dir_name)
        album_match = album_tag.match(/\(Disc (\d+)[ ):]/)
        dir_match = file_dir_name.match(/^disc_(\d+)/)

        tag_num = album_match.nil? ? nil : album_match[1].to_i
        dir_num = dir_match.nil? ? nil : dir_match[1].to_i

        return true if tag_num == dir_num

        raise Aur::Exception::InvalidTagValue, disc_error(tag_num, dir_num)
      end

      def optional_tags
        %i[encoder tsse tlen]
      end

      def self.help
        <<~EOHELP
          usage: aur lint <file>...

          Checks a file, ensuring that:
            - the filename is correctly formatted
            - all and only required tags are present
            - said tags are populated with sane values
        EOHELP
      end

      private

      def disc_error(tag_num, dir_num)
        if tag_num.nil? && dir_num
          'file in disc_ dir, but has no disc number in album tag'
        elsif tag_num && dir_num.nil?
          "album tag: disc #{tag_num} but not in disc_ dir"
        else
          "album tag: disc #{tag_num}; directory disc #{dir_num}"
        end
      end

      def in_tracks?
        file.expand_path.lastdir == 'tracks'
      end

      def validate_tags(tags)
        tags.each do |tag, value|
          check_tag(tag, value)
        rescue NoMethodError
          raise Aur::Exception::InvalidTagValue, "Unparseable tag: #{value}"
        end
      end

      def check_tag(tag, value)
        return if validator.send(tag, value)

        msg = opts[:summary] ? tag : "#{tag}: #{value}"
        err(Aur::Exception::InvalidTagValue.new,
            file, "Invalid tag value: #{msg}")
      end

      def required_tags
        REQ_TAGS[info.filetype.to_sym]
      end

      def name_checks_out?(chunks)
        chunks.count == 4 && chunks.all?(&:safe?) && chunks.first.safenum? &&
          !chunks[1].start_with?('the_')
      end
    end
    # rubocop:enable Metrics/ClassLength

    # Extra MP3 things
    #
    module LintMp3
      #
      # If there's a corresponding FLAC to this MP3, check the MP3 isn't over
      # 128kbps. If there is, any bitrate is fine.
      #
      def reasonable_bitrate?
        return true unless @info.partner.exist?
        return true if @info.raw_bitrate <= MP3_BITRATE

        # Give VBRs an allowance. When we encode at 128 VBR it can show in the
        # 140s.
        #
        if @info.raw_bitrate <= 1.2 * MP3_BITRATE &&
           @info.bitrate.include?('variable')
          return true
        end

        raise Aur::Exception::LintHighBitrateMp3, @info.raw_bitrate
      end
    end

    # We have different rules for things in a tracks/ directory.
    #
    module LintTracks
      # rubocop:disable Metrics/AbcSize
      def correct_tag_values?
        unless info.our_tags[:album].nil?
          raise Aur::Exception::InvalidTagValue, 'Album tag should not be set'
        end

        unless info.t_num == '1'
          raise Aur::Exception::InvalidTagValue, 'Track number must be 1'
        end

        tags = info.our_tags.except(:album)
        optional_tags.each { |t| tags.delete(t) if tags[t].nil? }
        validate_tags(tags)
      end

      # We won't complain whether we have a year tag or not
      #
      def unwanted_tags?
        unwanted_tags = info.tags.keys - required_tags - [:encoder]
        return true if unwanted_tags.empty? || unwanted_tags == [:tyer]

        raise Aur::Exception::LintUnwantedTags, unwanted_tags.join(', ')
      end
      # rubocop:enable Metrics/AbcSize

      private

      def name_checks_out?(chunks)
        chunks.count == 3 && chunks.all?(&:safe?) &&
          !chunks[0].start_with?('the_')
      end

      def optional_tags
        %i[date talb tyer year genre]
      end
    end
  end
end

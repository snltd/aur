# frozen_string_literal: true

require 'pathname'
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
    class Lint
      attr_reader :file, :info, :opts, :validator

      def initialize(file = nil, opts = {})
        @file = file
        extend Aur::Command::LintTracks if in_tracks?
        @info = Aur::FileInfo.new(file)
        @opts = opts
        @validator = Aur::TagValidator.new(info, opts)
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
      rescue Aur::Exception::LintBadName
        err(file, 'Invalid file name')
      rescue Aur::Exception::LintMissingTags => e
        err(file, "Missing tags: #{e}")
      rescue Aur::Exception::LintUnwantedTags => e
        err(file, "Unwanted tags: #{e}")
      rescue Aur::Exception::InvalidTagValue => e
        err(file, "Invalid tag value: #{e}")
      end
      # rubocop:enable Metrics/MethodLength

      def err(file, msg)
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

      # Do we have the tags we expect to have? For now, at least, we're not
      # going to worry about additional tags.
      #
      def correct_tags?
        missing_tags?
        unwanted_tags?
      end

      def missing_tags?
        missing_tags = required_tags - info.tags.keys - optional_tags
        return true if missing_tags.empty?

        raise Aur::Exception::LintMissingTags, missing_tags.join(', ')
      end

      def unwanted_tags?
        unwanted_tags = info.tags.keys - required_tags
        return true if unwanted_tags.empty?

        raise Aur::Exception::LintUnwantedTags, unwanted_tags.join(', ')
      end

      # Are tags (reasonably) correctly populated?
      #
      def correct_tag_values?
        validate_tags(info.our_tags)
      end

      def optional_tags
        []
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
        err(file, "Invalid tag value: #{msg}")
      end

      def required_tags
        REQ_TAGS[info.filetype.to_sym]
      end

      def name_checks_out?(chunks)
        chunks.count == 4 && chunks.all?(&:safe?) && chunks.first.safenum? &&
          !chunks[1].start_with?('the_')
      end
    end

    # We have different rules for things in a tracks/ directory.
    #
    module LintTracks
      def correct_tag_values?
        unless info.our_tags[:album].nil?
          raise Aur::Exception::InvalidTagValue, 'Album tag should not be set'
        end

        tags = info.our_tags.except(:album)
        optional_tags.each { |t| tags.delete(t) if tags[t].nil? }
        validate_tags(tags)
      end

      # We won't complain whether we have a year tag or not
      #
      def unwanted_tags?
        unwanted_tags = info.tags.keys - required_tags
        return true if unwanted_tags.empty? || unwanted_tags == [:tyer]

        raise Aur::Exception::LintUnwantedTags, unwanted_tags.join(', ')
      end

      private

      def name_checks_out?(chunks)
        chunks.count == 3 && chunks.all?(&:safe?) &&
          !chunks[0].start_with?('the_')
      end

      def optional_tags
        %i[date talb tyer year t_num genre]
      end
    end
  end
end

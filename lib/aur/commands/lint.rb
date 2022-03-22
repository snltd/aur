# frozen_string_literal: true

require 'pathname'
require_relative 'base'
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

      def lint(file)
        correctly_named?(file)
        correct_tags?
        correct_tag_values?
      rescue Aur::Exception::LintBadName
        err(file, 'Invalid file name')
      rescue Aur::Exception::LintBadTags => e
        err(file, "Bad tags: #{e}")
      rescue Aur::Exception::InvalidTagValue => e
        err(file, "Bad tag value: #{e}")
      end

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
        return correctly_named_tracks?(file) if in_tracks?

        chunks = file.basename.to_s.split('.')

        if chunks.count == 4 &&
           chunks.all?(&:safe?) &&
           chunks.first.safenum? &&
           !chunks[1].start_with?('the_')
          return true
        end

        raise Aur::Exception::LintBadName
      end

      # Unless it's in tracks/, in which case there should be no leading
      # number.
      def correctly_named_tracks?(file)
        chunks = file.basename.to_s.split('.')

        if chunks.count == 3 && chunks.all?(&:safe?) &&
           !chunks[0].start_with?('the_')
          return true
        end

        raise Aur::Exception::LintBadName
      end

      # Do we have the tags we expect to have? For now, at least, we're not
      # going to worry about additional tags.
      #
      def correct_tags?
        missing_tags = REQ_TAGS[info.filetype.to_sym] - info.tags.keys

        if in_tracks?
          missing_tags.delete(:talb)
          missing_tags.delete(:tyer)
        end

        return true if missing_tags.empty?

        raise Aur::Exception::LintBadTags, missing_tags.join(', ')
      end

      # Are tags (reasonably) correctly populated?
      #
      def correct_tag_values?
        return correct_tag_values_tracks? if in_tracks?

        info.our_tags.each do |tag, value|
          unless validator.send(tag, value)
            msg = opts[:summary] ? tag : "#{tag}: #{value}"
            err(file, "Bad tag value: #{msg}")
          end
        rescue NoMethodError
          raise Aur::Exception::InvalidTagValue, "Unparseable tag: #{value}"
        end
      end

      # Are tags (reasonably) correctly populated?
      #
      def correct_tag_values_tracks?
        unless info.our_tags[:album].nil?
          raise Aur::Exception::InvalidTagValue, 'Album tag should not be set'
        end

        info.our_tags.except(:album).each do |tag, value|
          unless validator.send(tag, value)
            msg = opts[:summary] ? tag : "#{tag}: #{value}"
            err(file, "Bad tag value: #{msg}")
          end
        rescue NoMethodError
          raise Aur::Exception::InvalidTagValue, "Unparseable tag: #{value}"
        end
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
        file.realpath.lastdir == 'tracks'
      end
    end
  end
end

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
      attr_reader :file, :opts, :validator

      def initialize(file = nil, opts = {})
        @file = file
        @opts = opts
        @validator = Aur::TagValidator.new
      end

      def run
        lint(@file)
      rescue Errno::ENOENT
        warn "'#{@file}' not found."
        false
      end

      def lint(file)
        correctly_named?(file)
        correct_tags?(file)
        correct_tag_values?(file)
      rescue Aur::Exception::LintBadName
        err(file, 'Invalid file name')
      rescue Aur::Exception::LintBadTags => e
        err(file, "Bad tags: #{e}")
      rescue Aur::Exception::InvalidTagValue => e
        err(file, "Bad tag value: #{e}")
      rescue StandardError => e
        warn "Bombed on #{file}"
        pp e
      end

      def err(file, msg)
        warn(format('%-110<file>s    %<msg>s', file: file, msg: msg))
      end

      # A "proper" file name should be of the form
      # 'track_number.artist_name.title.suffix'.
      #
      def correctly_named?(file)
        chunks = file.basename.to_s.split('.')

        if chunks.count == 4 &&
           chunks.all?(&:safe?) &&
           chunks.first.safenum? &&
           !chunks[1].start_with?('the_')
          return true
        end

        raise Aur::Exception::LintBadName
      end

      # Do we have the tags we expect to have? For now, at least, we're not
      # going to worry about additional tags.
      #
      def correct_tags?(file)
        info, type = fileinfo(file)

        missing_tags = REQ_TAGS[type] - info.tags.keys

        return true if missing_tags.empty?

        raise Aur::Exception::LintBadTags, missing_tags.join(', ')
      end

      # Are tags (reasonably) correctly populated?
      # TODO re-use the info object
      #
      def correct_tag_values?(file)
        info, _type = fileinfo(file)

        info.our_tags.each do |tag, value|
          unless validator.send(tag, value)
            err(file, "Bad tag value: #{tag}: #{value}")
          end
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

      def fileinfo(file)
        if file.extname == '.flac'
          [Aur::FileInfo::Flac.new(file), :flac]
        else
          [Aur::FileInfo::Mp3.new(file), :mp3]
        end
      end
    end
  end
end

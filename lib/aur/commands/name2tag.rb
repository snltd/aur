# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../tag_factory'
require_relative '../stdlib/string'

module Aur
  module Command
    #
    # Retag a file from its name
    #
    class Name2tag < Base
      TAGS = %i[artist title album t_num].freeze
      TAG_FACTORY = Aur::TagFactory.new

      def run
        puts file
        tagger.tag!(tags_from_filename)
      end

      # @return [Hash] :tag_name => 'Nicely Formatted String'
      #
      def tags_from_filename
        TAGS.each_with_object({}) do |tag, aggr|
          aggr[tag] = TAG_FACTORY.title(info.send(:"f_#{tag}"))
        end
      end

      def self.help
        <<~EOHELP
          usage: aur name2tag <file>...

          Takes the name of the file and turns it into tags. This will only work
          correctly if the filename follows the format

            <track_num>.<artist>.<title>.suffix

          The album tag is taken from the name of the directory containing the
          file, assuming the format

            <artist>.<album>
        EOHELP
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../make_tag'
require_relative '../stdlib/string'

module Aur
  module Command
    #
    # Retag a file from its name
    #
    class Name2tag < Base
      include Aur::MakeTag

      TAGS = %i[artist title album t_num].freeze

      def run
        puts file
        tagger.tag!(tags_from_filename)
      end

      # @return [Hash] :tag_name => 'Nicely Formatted String'
      #
      def tags_from_filename
        TAGS.each_with_object({}) do |tag, aggr|
          aggr[tag] = mk_title(info.send("f_#{tag}".to_sym))
        end
      end
    end
  end
end

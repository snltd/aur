# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../make_tag'
require_relative '../stdlib/string'

module Aur
  module Name2tag
    #
    # Retag a file from its name
    #
    class Generic < Aur::Base
      include Aur::MakeTag

      TAGS = %i[artist title album t_num].freeze

      def run
        puts file
        tags = tags_from_filename
        tags.each_pair { |k, v| tag_msg(k, v) }
        tagger.tag!(tags)
      end

      private

      # @return [Hash] tag_name => value
      #
      def tags_from_filename
        TAGS.each_with_object({}) do |t, a|
          a[info.send(:tag_for, t)] = mk_title(info.send("f_#{t}".to_sym))
        end
      end

      def tag_msg(name, val)
        msg format('%12<tag_name>s -> %<tag_value>s',
                   tag_name: name,
                   tag_value: val)
      end
    end
  end
end

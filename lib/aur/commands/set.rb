# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Set the given tag(s) in the given file(s)
    #
    class Set < Base
      def run
        tagger.tag!(opts[:'<tag>'].to_sym => opts[:'<value>'])
      end
    end
  end
end

# frozen_string_literal: true

require 'pathname'

module Aur
  module Mixin
    #
    # Methods to help deal with files in our expected hierarchy
    #
    module FileTree
      # @param dir [Pathname] top-level directory
      # @param suffix [String] filetype suffix with leading dot
      # @return [Array[Array[Pathname, Int]]] arrays pairing relative path of
      #   a content directory with the number of audio files inside it
      #
      def content_under(root, suffix)
        Pathname.glob("#{root}/**/").each_with_object([]) do |dir, aggr|
          fcount = dir.children.count { |d| d.extname == suffix }
          aggr << [dir.relative_path_from(root), fcount] if fcount.positive?
        end.sort
      end

      # @return [Hash] map of a file to its name with the numeric prefix
      #   removed
      def files_under(root, suffix)
        Pathname.glob("#{root}/**/*")
                .select(&:file?)
                .select { |f| f.extname == suffix }
                .to_h { |f| [f, f.no_tnum] }
      end
    end
  end
end

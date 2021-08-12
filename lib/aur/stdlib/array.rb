# frozen_string_literal: true

require 'pathname'

# Extensions to stdlib Array
#
class Array
  # @return [Array[Pathname]] strings turned to pathnames
  def to_paths
    map { |s| Pathname.new(s) }
  end
end

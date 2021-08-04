# frozen_string_literal: true

# Extensions to stdlib Pathname
#
class Pathname
  # @return [String] capitalized version of the file extension
  #
  def extclass
    extname.delete('.').capitalize
  end

  # prefix the file name, leaving the path intact.
  # @return [Pathname]
  #
  def prefixed(prefix = '_')
    dirname + "#{prefix}#{basename}"
  end
end

# frozen_string_literal: true

# Extensions to stdlib Pathname
#
class Pathname
  # @return [String] capitalized version of the file extension
  #
  def extclass
    extname.delete('.').capitalize
  end
end

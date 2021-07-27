# frozen_string_literal: true

# Extensions to stdlib Numeric
#
class Numeric
  # @return [String] number, prefixed with leading zero
  def to_n
    format('%02d', self)
  end
end

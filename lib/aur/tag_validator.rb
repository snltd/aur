# frozen_string_literal: true

module Aur
  #
  # Collection of methods to compare tag values to our standards
  #
  class TagValidator
    def artist(artist)
      !(artist.empty? || artist.include?('&') || artist != artist.strip)
    end

    alias album artist
    alias title artist

    def year(year)
      year.to_i.between?(1955, Time.now.year)
    end

    def t_num(num)
      num.match(/^[1-9][0-9]?$/)
    end

    def genre(genre)
      return false if genre.nil?

      !genre.empty?
    end
  end
end

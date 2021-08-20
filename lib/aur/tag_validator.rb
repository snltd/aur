# frozen_string_literal: true

require_relative 'tag_factory'

module Aur
  #
  # Collection of methods to compare tag values to our standards
  #
  class TagValidator
    def initialize
      @tag_factory = Aur::TagFactory.new
    end

    def artist(artist)
      return false if artist.nil?

      !(artist.empty? || artist.include?('&') || artist != artist.strip)
    end

    alias album artist
    alias title artist

    def year(year)
      return false if year.nil?

      year.to_s.match?(/^[12]\d{3}$/) && year.to_i.between?(1938, Time.now.year)
    end

    def t_num(num)
      return false if num.nil?

      num.match(/^[1-9][0-9]?$/)
    end

    def genre(genre)
      return false if genre.nil? || genre.empty?

      genre == @tag_factory.genre(genre)
    end
  end
end

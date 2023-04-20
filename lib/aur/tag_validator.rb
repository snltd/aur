# frozen_string_literal: true

require_relative 'tag_factory'

module Aur
  #
  # Collection of methods to compare tag values to our standards. Linting can
  # be "lax", just looks to see if the supplied tag value matches some set of
  # rules, or "strict", in which an expected tag value is derived from the
  # file's name and compared to the given value.
  #
  class TagValidator
    attr_reader :info, :tag_factory, :opts

    def initialize(info = nil, opts = {})
      @info = info
      @opts = opts
      @tag_factory = Aur::TagFactory.new

      extend TagValidatorCommon

      if opts[:strict]
        extend TagValidatorStrict
      else
        extend TagValidatorLax
      end
    end
  end

  # Strict linting compares the actual tag values with calculated ones.
  #
  module TagValidatorStrict
    def artist(artist)
      return false if artist.nil?

      artist == tag_factory.artist(info.f_artist) ||
        artist == tag_factory.artist("the_#{info.f_artist}")
    end

    # We ignore certain punctuation in titles. We have no way of encoding
    # things like commas and question marks in our filename schema.
    #
    def title(title)
      return false if title.nil?

      title.delete(',?!') == tag_factory.title(info.f_title)
    end

    def album(album)
      return false if album.nil?

      album == tag_factory.album(info.f_album)
    end

    def t_num(num)
      return false if num.nil?

      num == tag_factory.t_num(info.f_t_num)
    end
  end

  # Lax linting runs a string against some simple rules.
  #
  module TagValidatorLax
    def artist(string)
      return false if string.nil?

      !string.empty? && !string.include?('&') && !string.include?(';') &&
        string.strip == string
    end

    alias title artist
    alias album artist

    def t_num(num)
      return false if num.nil?

      num.to_i.to_s == num && num.to_i.positive?
    end
  end

  # Some tags are validated in the same way whether strict or lax (because
  # their values cannot be derived from the filename.)
  #
  module TagValidatorCommon
    # Years can be nil
    def year(year)
      return true if year.nil?

      year.to_s.match?(/^[12]\d{3}$/) && year.to_i.between?(1938, Time.now.year)
    end

    def genre(genre)
      if genre.nil? || genre.empty? || !genre.match?(/^[A-Z][a-zA-Z\- ]+$/)
        return false
      end

      genre == tag_factory.genre(genre)
    end
  end
end

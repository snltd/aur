# frozen_string_literal: true

require_relative 'stdlib/numeric'
require_relative 'stdlib/string'
require_relative 'logger'
require_relative 'exception'

module Aur
  #
  # Methods to help with naming files.
  #
  module Renamers
    include Aur::Logger

    def track_fnum(info)
      format('%02d', info.t_num.to_i || 0)
    end

    # @return [String] the artist name, taken from the tag and turned into a
    #   safe filename segment.
    def artist_fname(info)
      (info.artist || 'unknown_artist').to_safe.sub(/^the_/, '')
    end

    # @return [String] the album name, taken from the tag and turned into a
    #   safe filename segment.
    def album_fname(info)
      (info.album || 'unknown_album').to_safe
    end

    # @return [String] the track title, taken from the tag and turned into a
    #   safe filename segment.
    def track_fname(info)
      (info.title || 'no_title').to_safe
    end

    def file_suffix(info)
      (info.filetype || file.extname).to_safe
    end

    def rename_file(file, dest)
      if dest.exist? && dest.size.positive?
        warn "#{dest} already exists"
      else
        rename_message(file, dest)
        FileUtils.mv(file, dest)
      end
    end

    def rename_message(file, dest)
      msg format('%<from>s -> %<to>s', from: file.basename, to: dest.basename)
    end

    # Generates a new name for a file, if need be.
    # @param number [Int] new number for file
    # @tfile [Pathname] the file
    #
    def renumbered_file(number, tfile = file)
      basename = if /^\d\d\./.match?(tfile.basename.to_s)
                   tfile.basename.to_s.sub(/^\d\d/, number.to_n)
                 else
                   [number.to_n, tfile.basename.to_s].join('.')
                 end

      tfile.dirname + basename
    end

    def escaped(word)
      '"' + word.to_s.gsub(/"/, '\"') + '"'
    end
  end
end

# frozen_string_literal: true

require_relative 'base'

module Aur
  module Command
    #
    # Display information about a file.
    #
    class Info < Base
      def run
        fields.each_pair { |k, v| puts fmt_line(k, v) }
        puts
      end

      def fmt_line(key, value)
        format('%9<key>s : %<value>s', key: key, value: value)
      end

      # rubocop:disable Metrics/AbcSize
      def fields
        { Filename: file.basename.to_s,
          Type: file.extclass.upcase,
          Bitrate: info.bitrate,
          Artist: info.artist,
          Album: info.album,
          Title: info.title,
          Genre: info.genre,
          'Track no': info.t_num,
          Year: info.year }
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end

# frozen_string_literal: true

module Aur
  module Mixin
    #
    # FLAC -> MP3 stuff, shared by flac2mp3 and mp3dir
    #
    module Flac2mp3
      def construct_command(source, dest, tags)
        "#{BIN[:flac]} -dsc #{escaped(source)} | " \
          "#{BIN[:lame]} #{LAME_FLAGS} #{lame_tag_opts(tags)} " \
          "- #{escaped(dest)}"
      end

      def check_dependencies
        unless BIN[:flac].exist?
          raise(Aur::Exception::MissingBinary, BIN[:flac])
        end

        return if BIN[:lame].exist?

        raise(Aur::Exception::MissingBinary, BIN[:lame])
      end

      def lame_tag_opts(tags)
        lame_flag_map.each_pair.with_object([]) do |(flag, tag), aggr|
          aggr << "#{flag} #{escaped(tags[tag])}" if tags.fetch(tag, false)
        end.join(' ')
      end

      # Maps LAME's command-line tag options to what we call tags
      #
      def lame_flag_map
        { '--tt': :title,
          '--ta': :artist,
          '--tl': :album,
          '--ty': :year,
          '--tn': :t_num,
          '--tg': :genre }
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'
require_relative '../renamers'

module Aur
  module Command
    #
    # Re-encode a FLAC as an MP3, using preset parameters
    #
    class Flac2mp3 < Base
      include Aur::Renamers

      def run_flac
        info = Aur::FileInfo::Flac.new(file)
        cmd = construct_command(file, info.our_tags)
        puts "#{file} -> #{flipped_suffix(file, 'mp3')}"
        system(cmd)
      end

      def construct_command(file, tags)
        raise(MissingBinary, BIN[:flac]) unless BIN[:flac].exist?
        raise(MissingBinary, BIN[:lame]) unless BIN[:lame].exist?

        "#{BIN[:flac]} -dsc #{escaped(file)} | " \
          "#{BIN[:lame]} #{LAME_FLAGS} #{lame_tag_opts(tags)} " \
          "- #{escaped(flipped_suffix(file, 'mp3'))}"
      end

      def lame_tag_opts(tags)
        lame_flag_map.each_pair.with_object([]) do |(flag, tag), aggr|
          aggr.<< "#{flag} #{escaped(tags[tag])}" if tags.fetch(tag, false)
        end.join(' ')
      end

      def escaped(tag)
        '"' + tag.to_s.gsub(/"/, '\"') + '"'
      end

      def cuefile
        file.sub(/\.\w+$/, '.cue')
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

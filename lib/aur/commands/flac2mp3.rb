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

      def construct_command(file, tags)
        "#{BIN[:flac]} -dsc #{escaped(file)} | " \
          "#{BIN[:lame]} #{LAME_FLAGS} #{lame_tag_opts(tags)} " \
          "- #{escaped(dest_file)}"
      end

      def dest_file
        file.sub_ext('.mp3')
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
          aggr.<< "#{flag} #{escaped(tags[tag])}" if tags.fetch(tag, false)
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

      def self.help
        <<~EOHELP
          usage: aur flac2mp3 <file>...

          Converts a FLAC into an MP3 using following preset values.

            #{LAME_FLAGS}

          The new MP3 file is created in the same directory as the FLAC, with
          the same filename, barring the suffix.

          Tags are copied from the FLAC.
        EOHELP
      end
    end

    # Transcode a single FLAC
    #
    module Flac2mp3Flac
      def run
        check_dependencies
        info = Aur::FileInfo.new(file)
        cmd = construct_command(file, info.our_tags)
        puts "#{file} -> #{dest_file}"
        system(cmd)
      end
    end
  end
end

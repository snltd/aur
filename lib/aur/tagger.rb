# frozen_string_literal: true

require_relative 'logger'
require_relative 'exception'

module Aur
  # Presents a unified interface to deal with tags across all supported
  # filetypes.
  #
  class Tagger
    attr_reader :info, :opts

    include Aur::Logger

    # @param info [Aur::Fileinfo::*]
    # @param opts [Hash]
    #
    def initialize(info, opts = {})
      @info = fileinfo(info)
      load_specifics
      @opts = opts
    end

    def tag_msg(name, value)
      msg format('%12<name>s -> %<value>s', name: name, value: value)
    end

    # Validate all tags. We're quite hardline here. If it can't be
    # validated, it can't be tagged, and we only validate the things we
    # care about. Validation can change a tag's type and/or value.
    #
    def validate(tags)
      return tags if opts[:novalidate]

      tags.tap do |t|
        t.each_pair do |name, value|
          validate_method = "validate_#{name}".to_sym

          unless respond_to?(validate_method)
            raise Aur::Exception::InvalidTagName, "cannot validate '#{name}'"
          end

          t[name] = send(validate_method, value)
        end
      end
    end

    def validate_title(value)
      value
    end

    alias validate_artist validate_title
    alias validate_album validate_title
    alias validate_genre validate_title

    def validate_year(year)
      ryear = year.to_i
      return ryear if ryear.between?(1940, Time.now.year)

      raise Aur::Exception::InvalidTagValue, "'#{year}' is an invalid year"
    end

    def validate_t_num(num)
      rnum = num.to_i

      if rnum.positive? ||
         (rnum.zero? && info.file.expand_path.dirname.basename.to_s == 'tracks')
        return rnum
      end

      raise Aur::Exception::InvalidTagValue, "'#{num}' is an invalid t_num"
    end

    private

    # We can be asked to operate on a naked file, or on a FileInfo object.
    # (This probably shouldn't be the case.)
    #
    def fileinfo(info)
      return info if info.respond_to?(:filetype)

      Aur::FileInfo.new(info)
    end

    def load_specifics
      case info.filetype
      when 'flac'
        extend Aur::TaggerFlac
      when 'mp3'
        extend Aur::TaggerMp3
      else
        raise Aur::Exception::UnsupportedFiletype, info.filetype
      end
    end
  end

  # Set tags for FLACs.
  #
  module TaggerFlac
    # @param tags [Hash] of tag_name => tag_value
    #
    def tag!(tags)
      validate(tags).each_pair do |name, value|
        tag_msg(name, value)
        info.raw.comment_del(info.tag_name(name))
        info.raw.comment_add("#{info.tag_name(name)}=#{value}")
      end

      info.raw.update!
    end

    # @param tags [Array] of tags to remove
    #
    def untag!(tags)
      tags.each do |name|
        info.raw.comment_del(name.to_s.upcase)
        info.raw.comment_del(name.to_s)
      end

      info.raw.update!
    end

    # flacinfo-rb doesn't appear to provide a way to manipulate blocks, so
    # it can't remove a picture. We'll have to shell out to metaflac(1).
    #
    def remove_picture
      res = system(remove_picture_cmd(info.file))

      raise Aur::Exception::FailedOperation, "strip #{info.file}" unless res
    end

    def remove_picture_cmd(file)
      "#{BIN[:metaflac]} --remove --block-type=PICTURE,PADDING " \
        "--dont-use-padding \"#{file}\""
    end
  end

  # Set Tags for MP3s.
  #
  module TaggerMp3
    def tag!(tags)
      Mp3Info.open(info.file) do |mp3|
        validate(tags).each_pair do |name, value|
          tag_msg(name, value)
          value = value.dup.force_encoding('UTF-8') if value.is_a?(String)
          mp3.tag2[info.tag_name(name)] = value
        rescue Encoding::CompatibilityError
          raise Aur::Exception::InvalidTagValue, "#{value} badly encoded"
        end
      end
    end

    # Looks like the only way to remove ID3 tags, with this library at
    # least, is to nuke them all and rewrite the ones you wanted to keep.
    #
    def untag!(tags)
      original_tags = info.tags

      Mp3Info.open(info.file) do |mp3|
        mp3.removetag1
        mp3.removetag2

        original_tags.reject { |k, _v| tags.include?(k) }.each do |k, v|
          mp3.tag2[k.upcase] = v
        end
      end
    end

    def remove_picture
      Mp3Info.open(info.file) do |mp3|
        mp3.tag2.remove_pictures
      end
    end
  end
end

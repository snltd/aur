# frozen_string_literal: true

require_relative 'logger'
require_relative 'exception'

module Aur
  module Tagger
    #
    # Base class for specialised taggers. Each tagger presents the same
    # interface.
    #
    class Base
      attr_reader :info, :opts

      include Aur::Logger

      # @param info [Aur::Fileinfo::*]
      # @param opts [Hash]
      def initialize(info, opts = {})
        @info = info
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
        tags.tap do |t|
          t.each_pair do |name, value|
            validate_method = "validate_#{name}".to_sym

            unless respond_to?(validate_method)
              raise(Aur::Exception::InvalidTagName, name)
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

      def validate_year(year)
        ryear = year.to_i
        return ryear if ryear.between?(1940, Time.now.year)

        raise(Aur::Exception::InvalidTagValue, year)
      end

      def validate_t_num(num)
        rnum = num.to_i
        return rnum if rnum.positive?

        raise(Aur::Exception::InvalidTagValue, num)
      end

      def validate_genre(genre)
        genre.capitalize
      end
    end

    # Set tags for FLACs.
    #
    class Flac < Base
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
    end

    # Set Tags for MP3s.
    #
    class Mp3 < Base
      def tag!(tags)
        Mp3Info.open(info.file) do |mp3|
          validate(tags).each_pair do |name, value|
            tag_msg(name, value)
            mp3.tag[info.tag_name(name)] = value
          end
        end
      end
    end
  end
end

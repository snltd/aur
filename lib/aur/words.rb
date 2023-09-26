# frozen_string_literal: true

require_relative 'constants'

module Aur
  #
  # Used by tagging methods and stdlib string to be smart-ish about
  # capitalisation.
  #
  class Words
    attr_reader :no_caps, :all_caps, :ignore_case, :expand

    def initialize(user_conf = CONF)
      preset_conf = TAGGING
      user_conf = user_conf.fetch(:tagging, {})

      @no_caps = merge_key(preset_conf, user_conf, :no_caps)
      @all_caps = merge_key(preset_conf, user_conf, :all_caps)
      @ignore_case = merge_key(preset_conf, user_conf, :ignore_case)
      @expand = preset_conf.fetch(:expand, {})
                           .merge(user_conf.fetch(:expand, {}))
    end

    private

    def merge_key(preset_conf, user_conf, key)
      preset_conf.fetch(key, []) + user_conf.fetch(key, [])
    end
  end
end

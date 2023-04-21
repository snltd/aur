# frozen_string_literal: true

module Aur
  #
  # Methods which are useful in multiple places
  #
  module Helpers
    def escaped(word)
      "\"#{word.to_s.gsub(/"/, '\"')}\""
    end

    # Blows up an array of directories to an array of those directories and
    # all the directories under them, uniquely sorted. Static, because it
    # only gets called from other static methods.
    # @param roots [Array[Pathname]]
    # @return [Array[Pathname]] all directories under all roots
    #
    def self.recursive_dir_list(dirs)
      (dirs + dirs.map { |d| Pathname.glob("#{d}/**/*/") }.flatten)
        .map(&:expand_path).sort.uniq
    end

    def format_time(seconds)
      return seconds.round(2).to_s if seconds < 1

      h = seconds / 3600
      m = seconds / 60 % 60
      s = seconds % 60

      if h < 1
        format('%<mins>d:%02<secs>d', mins: m, secs: s)
      else
        format('%<hours>d:%02<mins>d:%02<secs>d', hours: h, mins: m, secs: s)
      end
    end
  end
end

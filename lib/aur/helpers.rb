# frozen_string_literal: true

module Aur
  #
  # Methods which are useful in multiple places
  #
  module Helpers
    def escaped(word)
      '"' + word.to_s.gsub(/"/, '\"') + '"'
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
  end
end

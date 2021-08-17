# frozen_string_literal: true

module Aur
  #
  # Nothing fancy here. Just named exceptions to make things clearer.
  #
  class Exception
    class Collector < RuntimeError; end

    class FailedOperation < RuntimeError; end

    class FileExists < RuntimeError; end

    class InvalidInput < RuntimeError; end

    class InvalidTagName < RuntimeError; end

    class InvalidTagValue < RuntimeError; end

    class InvalidValue < RuntimeError; end

    class LintBadName < RuntimeError; end

    class LintBadTags < RuntimeError; end

    class LintDirBadFile < RuntimeError; end

    class LintDirBadFileCount < RuntimeError; end

    class LintDirBadName < RuntimeError; end

    class LintDirMissingCoverArt < RuntimeError; end

    class LintDirMixedFiles < RuntimeError; end

    class LintDirUnsequencedFile < RuntimeError; end

    class LintDirUnwantedCoverArt < RuntimeError; end

    class MissingBinary < RuntimeError; end

    class UnsupportedFiletype < RuntimeError; end
  end
end

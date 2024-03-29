# frozen_string_literal: true

module Aur
  #
  # Nothing fancy here. Just named exceptions to make things clearer.
  #
  class Exception
    class ArtfixNilSize < RuntimeError; end

    class Collector < RuntimeError; end

    class FailedOperation < RuntimeError; end

    class FileExists < RuntimeError; end

    class InvalidInput < RuntimeError; end

    class InvalidTagName < RuntimeError; end

    class InvalidTagValue < RuntimeError; end

    class InvalidValue < RuntimeError; end

    class LintBadName < RuntimeError; end

    class LintDodgyTag < RuntimeError; end

    class LintDuplicateTags < RuntimeError; end

    class LintHasByteOrder < RuntimeError; end

    class LintHighBitrateMp3 < RuntimeError; end

    class LintMissingTags < RuntimeError; end

    class LintUnwantedTags < RuntimeError; end

    class LintDirBadFile < RuntimeError; end

    class LintDirBadFileCount < RuntimeError; end

    class LintDirBadName < RuntimeError; end

    class LintDirInconsistentTags < RuntimeError; end

    class LintDirCoverArtMissing < RuntimeError; end

    class LintDirCoverArtNotSquare < RuntimeError; end

    class LintDirCoverArtTooBig < RuntimeError; end

    class LintDirCoverArtTooSmall < RuntimeError; end

    class LintDirCoverArtUnwanted < RuntimeError; end

    class LintDirUndercompressed < RuntimeError; end

    class LintDirMixedFiles < RuntimeError; end

    class LintDirUnsequencedFile < RuntimeError; end

    class MissingBinary < RuntimeError; end

    class UnsupportedFiletype < RuntimeError; end
  end
end

# frozen_string_literal: true

module Aur
  #
  # Helper methods for re-encoding/transcoding things
  #
  module Reencoders
    def operate_and_overwrite(file)
      intermediate_file = file.prefixed

      cmd = construct_cmd(file, intermediate_file)
      puts "#{file} -> #{file} [re-encoded]"

      if system(cmd)
        FileUtils.mv(intermediate_file, file)
      else
        FileUtils.rm(intermediate_file)
        raise Aur::Exception::FailedOperation, "reencode #{file}"
      end
    end

    def check_dependencies
      return if BIN[:ffmpeg].exist?

      raise(Aur::Exception::MissingBinary, BIN[:ffmpeg])
    end
  end
end

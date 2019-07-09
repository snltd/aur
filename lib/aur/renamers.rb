# frozen_string_literal: true

module Aur
  #
  # Methods to help with naming files.
  #
  module Renamers
    def track_fnum(info)
      format('%02d', info.t_num || 0)
    end

    def artist_fname(info)
      (info.artist || 'unknown_artist').to_safe
    end

    def album_fname(info)
      (info.album || 'unknown_album').to_safe
    end

    def track_fname(info)
      (info.title || 'no_title').to_safe
    end

    def file_suffix(info)
      (info.filetype || file.extname).to_safe
    end

    def rename_file(file, dest)
      if dest.exist?
        puts "ERROR: '#{dest}' exists."
        return
      end

      rename_message(file, dest)

      FileUtils.mv(file, dest)
    end

    def rename_message(file, dest)
      msg format('%<from>s -> %<to>s',
                 from: file.basename,
                 to: dest.basename)
    end
  end
end

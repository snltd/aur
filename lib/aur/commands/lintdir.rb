# frozen_string_literal: true

require 'pathname'
require_relative 'base'

module Aur
  module Command
    def run
      puts file
    end
  end
end
=begin
# Recurses down a file hierarchy looking at directories containing numbered
# FLACs or MP3s, and makes sure there are the right amount of them, and that
# they are numbered correctly. Tries to tell you what's wrong. Doesn't check
# the tags.

abort 'usage: check_file_count <dir>' unless ARGV.size == 1

root = Pathname.new(ARGV.first).realpath

abort 'cannot find root' unless root.exist?

if root.to_s.include?('flac')
  pattern = '.flac'
elsif root.to_s.include?('mp3') || root.to_s.include?('ipod')
  pattern = '.mp3'
else
  abort 'file path does not contain flac or mp3'
end

def filenum(file)
  file.basename.to_s.split('.').first
end

Pathname.glob("#{root}/**/*/").each do |dir|
  files = dir.children.select { |f| f.extname == pattern }.sort
  errs = []
  skip_each_check = false

  next if files.empty?

  topnum = filenum(files.last).to_i

  errs.<<("Expected #{topnum}, got #{files.size}") unless files.size == topnum

  1.upto(topnum) do |n|
    index = format('%02d', n)

    unless files.any? { |f| f.basename.to_s.start_with?("#{index}.") }
      errs.<<("missing file #{index}")
      skip_each_check = true
    end
  end

  unless skip_each_check
    files.each.with_index(1) do |f, i|
      index = format('%02d', i)
      unless f.basename.to_s.start_with?("#{index}.")
        errs.<<("#{f.basename} is not number #{index}")
      end
    end
  end

  next if errs.empty?

  puts dir
  errs.each { |e| puts "  #{e}" }
end
=end

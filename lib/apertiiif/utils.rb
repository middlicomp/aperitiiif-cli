# frozen_string_literal: true

require 'csv'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Utils
    def self.basename_no_ext(str)   = rm_ext File.basename(str)
    def self.rm_ext(str)            = str.sub File.extname(str), ''
    def self.parent_id(str, dir)    = prune_prefix_junk(rm_ext(str.sub(dir, '')))
    def self.parent_dir(str)        = File.dirname(str).split('/').last
    def self.prune_prefix_junk(str) = str.sub(/^(_|\W+)/, '')
    def self.mime(path) = MimeMagic.by_magic(File.open(path)).to_s
    def self.valid_source?(path) = File.file?(path) && path.end_with?(*ALLOWED_SRC_FORMATS)

    def self.slugify(str)
      str.downcase!
      str.strip!
      str.gsub! ' ', '-'
      str.gsub!(/[^\w-]/, '')
      prune_prefix_junk str
    end

    def self.formatted_datetime(time = Time.now)
      fmt_date  = "#{time.month}/#{time.day}/#{time.year}"
      fmt_time  = "#{time.hour}:#{time.min.to_s.rjust(2, '0')}#{time.zone}"
      "#{fmt_date} at #{fmt_time}"
    end

    def self.item_assets_from_path(path)
      return [path] if Utils.valid_source?(path)
      return [] unless File.directory? path

      Dir.glob("#{path}/*").select { |sub| Utils.valid_source? sub }
    end

    def self.csv_records(file, defaults = {})
      hashes = CSV.read(file, headers: true).map(&:to_hash)
      hashes.map { |hash| Record.new hash.compact, defaults }
    end

    def self.mkfile_p(path, contents)
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') { |file| file.write contents }
    end
  end
end

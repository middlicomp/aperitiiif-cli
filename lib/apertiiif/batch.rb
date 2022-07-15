# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'json'
require 'parallel'
require 'progress_bar'
require 'rainbow'
require 'safe_yaml'
require 'vips'

require_relative 'batch/indexable'
require_relative 'batch/lintable'

# TO DO COMMENT
module Apertiiif
  CONFIG  = Apertiiif::Config.new
  FORMATS = %w[jpg jpeg png tif tiff].freeze

  # TO DO COMMENT
  class Batch
    include Indexable
    include Lintable

    def initialize
      @records = records
      @items = items
    end

    def reset
      puts Rainbow('Resetting build...').cyan
      FileUtils.rm_rf CONFIG.build_dir
      puts Rainbow('Done ✓').green
    end

    def collect_assets_paths(path)
      return [path] if File.file?(path) && path.end_with?(*FORMATS)
      return [] unless File.directory? path

      Dir.glob("#{path}/*").select { |p| p.end_with?(*FORMATS) }
    end

    def items
      Dir.glob("#{CONFIG.source_dir}/*").map do |p|
        asset_paths = collect_assets_paths p
        next if asset_paths.empty?

        id          = Apertiiif::Utils.basename p
        record      = @records.find { |r| r.id == id }
        Apertiiif::Item.new id, asset_paths, record
      end.compact
    end

    def records
      hashes = CSV.read(CONFIG.records_file, headers: true).map(&:to_hash)
      hashes.map do |h|
        h = CONFIG.records_defaults.merge h.compact
        OpenStruct.new h
      end
    rescue StandardError
      puts Rainbow("Could not load #{CONFIG.records_file}. Does it exist as a valid CSV?").magenta
      []
    end

    def assets
      @assets ||= @items.flat_map(&:assets)
    end

    def hashes
      @items.map(&:to_hash)
    end

    def build_image_api
      FileUtils.mkdir_p CONFIG.image_build_dir
      bar = ProgressBar.new :rate
      puts Rainbow('Writing target TIFs...').cyan
      Parallel.each assets do |a|
        a.write_to_target
        bar.increment!
      end
      puts Rainbow("\nDone ✓").green
    end

    def build_presentation_api
      FileUtils.mkdir_p CONFIG.presentation_build_dir
      bar = ProgressBar.new :rate
      puts Rainbow('Creating IIIF Presentation JSON...').cyan
      Parallel.each @items do |i|
        i.write_presentation_json
        bar.increment!
      end
      # TO DO !! build IIIF collection JSON
      puts Rainbow("\nDone ✓").green
    end
  end
end

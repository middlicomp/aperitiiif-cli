# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'json'
require 'parallel'
require 'progress_bar'
require 'rainbow'
require 'safe_yaml'
require 'vips'

require_relative 'asset'
require_relative 'config'
require_relative 'item'

# TO DO COMMENT
module Apertiiif
  CONFIG = Apertiiif::Config.new

  # TO DO COMMENT
  class Batch
    # attr_reader :items
    def initialize
      @records = records
      @items = items
    end

    def reset
      puts Rainbow('Resetting build...').cyan
      FileUtils.rm_rf CONFIG.build_dir
      puts Rainbow('Done ✓').green
    end

    def items
      Dir.glob("#{CONFIG.source_dir}/*").map do |f|
        assets   = File.file?(f) ? [f] : Dir.glob("#{f}/*")
        id       = Apertiiif::Utils.basename f
        record   = @records.find { |r| r.id == id }
        Apertiiif::Item.new id, assets, record
      end
    end

    # rubocop:disable Metrics/AbcSize
    def audit_records
      puts Rainbow('Auditing record and file pairings...').cyan
      nil_records = @items.select { |i| i.record.nil? }
      if nil_records.empty?
        puts Rainbow('Done ✓').green
      else
        puts Rainbow("Could not find records for #{nil_records.length} items:").orange
        nil_records.each { |n| puts Rainbow(n.id).yellow }
      end
    end
    # rubocop:enable Metrics/AbcSize

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

    def to_json(*_args)
      JSON.pretty_generate hashes
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

    def build_html_index
      FileUtils.mkdir_p CONFIG.html_build_dir
      puts Rainbow('Creating HTML index of items...').cyan
      index_file = "#{CONFIG.html_build_dir}/index.html"
      File.open(index_file, 'w') { |f| f.write to_html }
      puts Rainbow('Done ✓').green
    end

    def build_json_index
      FileUtils.mkdir_p CONFIG.html_build_dir
      puts Rainbow('Creating JSON index of items...').cyan
      index_file = "#{CONFIG.html_build_dir}/index.json"
      File.open(index_file, 'w') { |f| f.write to_json }
      puts Rainbow('Done ✓').green
    end

    def to_html
      <<~HTML
        <!DOCTYPE html><html lang="en">
          <head>
            <meta charset="UTF-8"><meta http-equiv="X-UA-Compatible" content="ie=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>apertiiif batch listing: #{CONFIG.batch_namespace}</title>
            <style>body {font-family: Sans-Serif;}</style>
          </head>
          <body>
            <h1>#{CONFIG.batch_namespace} apertiiif batch</h1>
            <p>last updated #{Apertiiif::Utils.formatted_time}</p>
            <h2>published items (#{@items.length})</h2>
            <ul>#{@items.map(&:to_html_list_item).join("\n")}</ul>
          </body>
        </html>
      HTML
    end
  end
end

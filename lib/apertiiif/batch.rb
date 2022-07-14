# frozen_string_literal: true

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
      @items = items
    end

    def reset
      puts Rainbow('Resetting build...').cyan
      FileUtils.rm_rf CONFIG.build_dir
    end

    def items
      Dir.glob("#{CONFIG.source_dir}/*").map do |f|
        assets = File.file?(f) ? [f] : Dir.glob("#{f}/*")
        id     = "#{CONFIG.batch_namespace}_#{Apertiiif::Utils.basename(f)}"
        Apertiiif::Item.new(id, assets, {})
      end
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
      puts '[ 1/1 ]'
      puts Rainbow('Done ✓').green
    end

    def build_json_index
      FileUtils.mkdir_p CONFIG.html_build_dir
      puts Rainbow('Creating JSON index of items...').cyan
      index_file = "#{CONFIG.html_build_dir}/index.json"
      File.open(index_file, 'w') { |f| f.write to_json }
      puts '[ 1/1 ]'
      puts Rainbow('Done ✓').green
    end

    def to_html
      <<~HTML
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta http-equiv="X-UA-Compatible" content="ie=edge">
            <title>apertiiif batch listing: #{CONFIG.batch_namespace}</title>
          </head>
          <body>
            <h1>#{CONFIG.batch_namespace} aperiiif batch</h1>
            <p>last updated #{Apertiiif::Utils.formatted_time}</p>
            <p>#{@items.length} total items in batch</p>
            <h2>published items</h2>
            <ul>
              #{@items.map(&:to_html_list_item).join("\n")}
            </ul>
          </body>
        </html>
      HTML
    end
  end
end

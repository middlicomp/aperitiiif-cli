# frozen_string_literal: true

require 'fileutils'
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

    def build_image_api
      FileUtils.mkdir_p CONFIG.image_build_dir
      bar = ProgressBar.new assets.length
      puts Rainbow('Writing target TIFs...').cyan
      assets.each do |a|
        a.write_to_target
        bar.increment!
      end
      puts Rainbow('Done ✓').green
    end

    def build_presentation_api
      FileUtils.mkdir_p CONFIG.presentation_build_dir
      bar = ProgressBar.new @items.length
      puts Rainbow('Creating IIIF Presentation JSON...').cyan
      @items.reverse_each do |i|
        i.write_to_json
        bar.increment!
      end
    end
  end
end

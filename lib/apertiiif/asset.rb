# frozen_string_literal: true

require 'iiif/presentation'
require 'mimemagic'
require 'vips'

# to do
module Apertiiif
  # to do
  # has smell :reek:TooManyMethods
  class Asset
    attr_reader :parent_id

    TARGET_EXT = '.tif'

    def initialize(parent_id, source, config)
      @parent_id  = parent_id
      @source     = source
      @config     = config
    end

    def id
      @id ||= build_id
    end

    def target
      @target ||= build_target
    end

    def build_id
      id = Utils.basename_no_ext @source
      id.prepend "#{@parent_id}_" unless id == @parent_id
      id.prepend "#{@config.batch_namespace}_"
    end

    def target_written?
      File.file? target
    end

    def build_target
      "#{@config.image_build_dir}/#{id}#{TARGET_EXT}"
    end

    def width
      # TO DO ERROR IF NOT WRITTEN
      @width ||= Vips::Image.new_from_file(target).width
    end

    def height
      # TO DO ERROR IF NOT WRITTEN
      @height ||= Vips::Image.new_from_file(target).height
    end

    def target_mime
      @target_mime ||= Utils.mime target
    end

    def source_mime
      @source_mime ||= Utils.mime @source
    end

    def write_to_target
      return if target_written?

      FileUtils.mkdir_p @config.image_build_dir

      image = Vips::Image.new_from_file @source
      image.write_to_file target
    end

    def canvas_url
      @canvas_url ||= "#{@config.presentation_api_url}/canvas/#{id}.json"
    end

    def thumbnail_url
      @thumbnail_url ||= "#{@config.image_api_url}/#{id}/full/250,/0/default.jpg"
    end

    def annotation_url
      @annotation_url ||= "#{@config.presentation_api_url}/annotation/#{id}.json"
    end

    def full_resource_url
      @full_resource_url ||= "#{@config.image_api_url}/#{id}/full/full/0/default.jpg"
    end

    def service_url
      @service_url ||= "#{@config.image_api_url}/#{id}"
    end

    def service
      {
        '@context' => 'http://iiif.io/api/image/2/context.json',
        '@id' => service_url
      }
    end

    def annotation
      opts = {
        '@id' => annotation_url,
        'on' => canvas_url,
        'resource' => resource
      }
      IIIF::Presentation::Annotation.new opts
    end

    def resource
      opts = {
        '@id' => full_resource_url,
        '@type' => 'dcterms:Image',
        'service' => service,
        'format' => target_mime
      }
      IIIF::Presentation::Resource.new opts
    end

    def canvas
      opts = {
        '@id' => canvas_url,
        'label' => id,
        'width' => width,
        'height' => height,
        'thumbnail' => thumbnail_url,
        'images' => [annotation]
      }
      IIIF::Presentation::Canvas.new opts
    end
  end
end

# frozen_string_literal: true

require 'iiif/presentation'
require 'mimemagic'
require 'vips'

# to do
module Apertiiif
  # to do
  class Asset
    attr_reader :id

    def initialize(source)
      @source = source
      @target = target
      @id     = Apertiiif::Utils.basename @target
    end

    def target_written?
      File.file? @target
    end

    def width
      # TO DO ERROR IF NOT WRITTEN
      @width ||= Vips::Image.new_from_file(@target).width
    end

    def height
      # TO DO ERROR IF NOT WRITTEN
      @height ||= Vips::Image.new_from_file(@target).height
    end

    def target
      @target ||= build_target
    end

    def build_target
      path_array = @source.sub(CONFIG.source_dir, '').split('/').reject(&:empty?)
      newname    = "#{CONFIG.image_build_dir}/#{path_array.prepend(CONFIG.batch_namespace).join('_')}"
      newname.sub File.extname(newname), '.tif'
    end

    def mime(path)
      MimeMagic.by_magic(File.open(path)).to_s
    end

    def target_mime
      @target_mime ||= mime @target
    end

    def source_mime
      @source_mime ||= mime @source
    end

    def write_to_target
      return if target_written?

      image = Vips::Image.new_from_file @source
      image.write_to_file @target
    end

    def canvas_url
      @canvas_url ||= "#{CONFIG.presentation_api_url}/canvas/#{@id}.json"
    end

    def thumbnail_url
      @thumbnail_url ||= "#{CONFIG.image_api_url}/#{@id}/full/250,/0/default.jpg"
    end

    def annotation_url
      @annotation_url ||= "#{CONFIG.presentation_api_url}/annotation/#{@id}.json"
    end

    def full_resource_url
      @full_resource_url ||= "#{CONFIG.image_api_url}/#{@id}/full/full/0/default.jpg"
    end

    def service_url
      @service_url ||= "#{CONFIG.image_api_url}/#{@id}"
    end

    def service
      s             = {}
      s['@context'] = 'http://iiif.io/api/image/2/context.json'
      s['@id']      = service_url
      s
    end

    def annotation
      a          = IIIF::Presentation::Annotation.new
      a['@id']   = annotation_url
      a['on']    = canvas_url
      a.resource = resource
      a
    end

    def resource
      r            = IIIF::Presentation::Resource.new
      r['@id']     = full_resource_url
      r['@type']   = 'dcterms:Image'
      r['service'] = service
      r.format     = target_mime
      r
    end

    def canvas
      c              = IIIF::Presentation::Canvas.new
      c['@id']       = canvas_url
      c.label        = @id
      c.width        = width
      c.height       = height
      c.thumbnail    = thumbnail_url
      c.images << annotation
      c
    end
  end
end

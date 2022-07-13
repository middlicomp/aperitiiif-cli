# frozen_string_literal: true

require 'iiif/presentation'
require 'mimemagic'
require 'progress_bar'
require 'rainbow'
require 'vips'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Api
    # TO DO COMMENT
    module Presentation
      def presentation_api
        FileUtils.mkdir_p @config.presentation_build_dir
        files = tif_files
        bar   = ProgressBar.new files.length
        puts Rainbow('Creating IIIF Presentation JSON...').cyan
        files.each do |file|
          image = Vips::Image.new_from_file file
          id    = File.basename(file).sub(File.extname(file), '')

          manifest            = IIIF::Presentation::Manifest.new
          manifest['@id']     = "#{@config.presentation_api_url}/#{id}/manifest.json"
          manifest['label']   = id

          sequence            = IIIF::Presentation::Sequence.new
          canvas              = IIIF::Presentation::Canvas.new

          canvas['@id']       = "#{@config.presentation_api_url}/canvas/#{id}.json"
          canvas.label        = id
          canvas.width        = image.width
          canvas.height       = image.height
          canvas.thumbnail    = "#{@config.image_api_url}/#{id}/full/250,/0/default.jpg"

          annotation          = IIIF::Presentation::Annotation.new
          annotation['@id']   = "#{@config.presentation_api_url}/annotation/#{id}.json"
          annotation['on']    = canvas['@id']

          resource            = IIIF::Presentation::Resource.new
          resource['@id']     = "#{@config.image_api_url}/#{id}/full/full/0/default.jpg"
          resource['@type']   = 'dcterms:Image'
          resource.format     = mime_type(file)

          service             = {}
          service['@context'] = 'http://iiif.io/api/image/2/context.json'
          service['@id']      = "#{@config.image_api_url}/#{id}/"

          resource['service'] = service
          annotation.resource = resource
          canvas.images       << annotation
          sequence.canvases   << canvas
          manifest.sequences  << sequence

          manifest_file = "#{@config.presentation_build_dir}/#{id}/manifest.json"
          FileUtils.mkdir_p File.dirname(manifest_file)
          File.open(manifest_file, 'w') { |m| m.write manifest.to_json(pretty: true) }
          bar.increment!
        end
        puts Rainbow('Done ✓').green
      end

      def mime_type(file)
        MimeMagic.by_magic(File.open(file)).to_s
      end
    end
  end
end

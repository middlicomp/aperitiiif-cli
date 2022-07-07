# frozen_string_literal: true

require 'iiif/presentation'
require 'mimemagic'
require 'vips'

FileUtils.mkdir_p PRESENTATION_BUILD_DIR

files = Dir.glob("#{IMAGE_BUILD_DIR}/**/*").select { |f| File.file? f }
files.each do |f|
  image = Vips::Image.new_from_file f
  mime  = MimeMagic.by_magic(File.open(f)).to_s
  id    = File.basename(f).gsub(File.extname(f), '')

  manifest            = IIIF::Presentation::Manifest.new
  manifest['@id']     = "#{PRESENTATION_API_URL}/#{id}/manifest.json"
  manifest['label']   = id

  sequence            = IIIF::Presentation::Sequence.new
  canvas              = IIIF::Presentation::Canvas.new

  canvas['@id']       = "#{PRESENTATION_API_URL}/canvas/#{id}.json"
  canvas.label        = id
  canvas.width        = image.width
  canvas.height       = image.height
  canvas.thumbnail    = "#{IMAGE_API_URL}/#{id}/full/250,/0/default.jpg"

  annotation          = IIIF::Presentation::Annotation.new
  annotation['@id']   = "#{PRESENTATION_API_URL}/annotation/#{id}.json"
  annotation['on']    = canvas['@id']

  resource            = IIIF::Presentation::Resource.new
  resource['@id']     = "#{IMAGE_API_URL}/#{id}/full/full/0/default.jpg"
  resource['@type']   = 'dcterms:Image'
  resource.format     = mime

  service             = {}
  service['@context'] = 'http://iiif.io/api/image/2/context.json'
  service['@id']      = "#{IMAGE_API_URL}/#{id}/"

  resource['service'] = service
  annotation.resource = resource
  canvas.images       << annotation
  sequence.canvases   << canvas
  manifest.sequences  << sequence

  manifest_file = "#{PRESENTATION_BUILD_DIR}/#{id}/manifest.json"
  FileUtils.mkdir_p File.dirname(manifest_file)
  File.open(manifest_file, 'w') { |m| m.write manifest.to_json(pretty: true) }
end

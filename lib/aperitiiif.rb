# frozen_string_literal: true

require 'colorize'
require 'thor'

require 'aperitiiif/asset'
require 'aperitiiif/batch'
require 'aperitiiif/cli'
require 'aperitiiif/config'
require 'aperitiiif/error'
require 'aperitiiif/index'
require 'aperitiiif/item'
require 'aperitiiif/record'
require 'aperitiiif/version'
require 'aperitiiif/utils'

# TO DO COMMENT
module Aperitiiif
  ALLOWED_SRC_FORMATS = %w[jpg jpeg png tif tiff].freeze
end

# frozen_string_literal: true

require 'rainbow'
require 'thor'

require 'apertiiif/asset'
require 'apertiiif/batch'
require 'apertiiif/cli'
require 'apertiiif/config'
require 'apertiiif/item'
require 'apertiiif/record'
require 'apertiiif/version'
require 'apertiiif/utils'

# TO DO COMMENT
module Apertiiif
  ALLOWED_SRC_FORMATS = %w[jpg jpeg png tif tiff].freeze

  # TO DO COMMENT
  class Error < StandardError
    def initialize(msg = '')
      super("#{self} => #{Rainbow(msg).magenta}")
    end
  end
end

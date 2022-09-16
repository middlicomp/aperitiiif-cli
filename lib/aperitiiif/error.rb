# frozen_string_literal: true

require 'colorize'

# TO DO COMMENT
module Aperitiiif
  # TO DO COMMENT
  class Error < RuntimeError
    def initialize(msg = '')
      puts msg.colorize(:magenta) and super('')
    end
  end
end

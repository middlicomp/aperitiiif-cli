# frozen_string_literal: true

require 'colorize'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Error < RuntimeError
    def initialize(msg = '')
      puts msg.colorize(:magenta) and super('')
    end
  end
end

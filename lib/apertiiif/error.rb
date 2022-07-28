# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Error < StandardError
    def initialize(msg = '')
      super("#{self} => #{Rainbow(msg).magenta}")
    end
  end
end

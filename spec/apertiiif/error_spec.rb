# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Apertiiif::Error do
  describe 'raise' do
    it 'sends custom message to stderr' do
      expect { warn Apertiiif::Error.new, 'test' }.to output(/test/).to_stderr
    end
  end
end

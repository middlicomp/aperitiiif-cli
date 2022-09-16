# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Aperitiiif::Error do
  describe 'raise' do
    it 'sends custom message to stderr' do
      quiet_stdout do
        expect { warn Aperitiiif::Error.new, 'test' }.to output(/test/).to_stderr
      end
    end
  end
end

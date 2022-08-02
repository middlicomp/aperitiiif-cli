# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter if ENV['CI']

SimpleCov.start do
  add_filter '/spec/'
end

require 'apertiiif'

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
end

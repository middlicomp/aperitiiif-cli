# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

QUIET               = !ENV['DEBUG']
ENV['VIPS_WARNING'] = '1'
BUILD_DIR           = './build'

SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter if ENV['CI']
SimpleCov.start do
  add_filter '/spec/'
end

FileUtils.rm_rf BUILD_DIR

require 'apertiiif'

# debug helper method
# :reek:DuplicateMethodCall
# :reek:TooManyStatements
# rubocop:disable Metrics/MethodLength
def quiet_stdout
  if QUIET
    begin
      orig_stderr = $stderr.clone
      orig_stdout = $stdout.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      retval = yield
    rescue StandardError => error
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
      raise error
    ensure
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
    end
    retval
  else
    yield
  end
end
# rubocop:enable Metrics/MethodLength

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
end

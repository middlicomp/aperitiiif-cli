# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

begin
  RSpec::Core::RakeTask.new :spec do |t|
    t.fail_on_error = false
  end

  task default: :spec
end

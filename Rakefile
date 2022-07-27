# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'reek/rake/task'
require 'rspec/core/rake_task'

begin
  RSpec::Core::RakeTask.new :spec do |t|
    t.fail_on_error = false
  end

  Reek::Rake::Task.new do |t|
    t.fail_on_error = false
  end

  task default: :spec
end

# frozen_string_literal: true

require_relative 'lib/apertiiif/version'

Gem::Specification.new do |spec|
  spec.name     = 'apertiiif'
  spec.version  = Apertiiif::VERSION
  spec.authors  = ['mnyrop']
  spec.email    = ['marii@nyu.edu']
  spec.summary  = ''
  spec.homepage = 'https://github.com/nyu-dss/apertiiif-cli'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri']     = spec.homepage
  spec.metadata['source_code_uri']  = 'https://github.com/nyu-dss/apertiiif-cli'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir         = 'bin'
  spec.executables    = ['apertiiif']
  spec.require_paths  = ['lib']

  spec.add_dependency 'iiif-presentation'
  spec.add_dependency 'mimemagic'
  spec.add_dependency 'parallel'
  spec.add_dependency 'progress_bar'
  spec.add_dependency 'rainbow'
  spec.add_dependency 'ruby-vips'
  spec.add_dependency 'safe_yaml'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rspec'
end

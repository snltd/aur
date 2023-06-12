# frozen_string_literal: true

require 'pathname'
require 'date'

# Github actions sets the RELEASE_VERSION environment variable

Gem::Specification.new do |gem|
  gem.name          = 'aur'
  gem.version       = ENV.fetch('RELEASE_VERSION',
                                "0.0.#{Time.now.strftime('%Y%m%d')}")

  gem.summary       = 'audio file management tool'
  gem.description   = 'audio file management tool'

  gem.authors       = ['Robert Fisher']
  gem.email         = 'services@id264.net'
  gem.homepage      = 'https://github.com/snltd/aur'
  gem.license       = 'BSD-2-Clause'

  gem.bindir        = 'bin'
  gem.files = Dir['bin/*', 'aur.gemspec', 'Gemfile*', 'lib/**/*', 'Rakefile']
  gem.executables = 'aur'

  gem.metadata['rubygems_mfa_required'] = 'true'

  gem.add_runtime_dependency 'colorize', '~> 0.8'
  gem.add_runtime_dependency 'docopt', '~> 0.6'
  gem.add_runtime_dependency 'fastimage', '~> 2.2'
  gem.add_runtime_dependency 'flacinfo-rb', '~> 1.0'
  gem.add_runtime_dependency 'i18n', '~> 1.12'
  gem.add_runtime_dependency 'ruby-mp3info', '~> 0.8'

  gem.required_ruby_version = Gem::Requirement.new('>= 3.0.0')
end

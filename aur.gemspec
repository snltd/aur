# frozen_string_literal: true

require 'pathname'
require 'date'

require_relative 'lib/aur/version'

Gem::Specification.new do |gem|
  gem.name          = 'Aur'
  gem.version       = AUR_VERSION
  gem.date          = Date.today.to_s

  gem.summary       = 'audio file management tool'
  gem.description   = 'audio file management tool'

  gem.authors       = ['Robert Fisher']
  gem.email         = 'services@id264.net'
  gem.homepage      = 'https://github.com/snltd/aur'
  gem.license       = 'BSD-2-Clause'

  gem.bindir        = 'bin'
  gem.files         = `git ls-files`.split("\n")
  gem.executables   = 'aur'
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = %w[lib]

  gem.add_runtime_dependency 'docopt', '~> 0.6.0'
  gem.add_runtime_dependency 'flacinfo-rb', '~> 1.0.0'
  gem.add_runtime_dependency 'i18n', '~> 1.6.0'
  gem.add_runtime_dependency 'ruby-mp3info', '~> 0.8.0'

  gem.add_development_dependency 'minitest', '~> 5.11', '>= 5.11.0'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'rubocop', '~> 0.72.0'
  gem.add_development_dependency 'spy', '~> 1.0.0'
  gem.add_development_dependency 'yard', '~> 0.9.5'

  gem.required_ruby_version = Gem::Requirement.new('>= 2.3.0')
end

# frozen_string_literal: true

require_relative 'lib/inat-get/info'

Gem::Specification::new do |spec|
  spec.name     =   INatGet::Info::NAME
  spec.version  =   INatGet::Info::VERSION
  spec.authors  = [ INatGet::Info::AUTHOR ]
  spec.email    = [ INatGet::Info::EMAIL  ]
  spec.license  =   INatGet::Info::LICENSE
  spec.summary  =   INatGet::Info::SUMMARY
  spec.homepage =   INatGet::Info::HOMEPAGE

  spec.required_ruby_version = '>= 3.4'

  spec.files = Dir[ '{lib,bin}/**/*', 'README.md', 'LICENSE' ]
  spec.bindir = 'bin'
  spec.executables = [ 'inat-get' ]

  spec.add_dependency 'sequel', '~> 5.101'
  spec.add_dependency 'faraday', '~> 2.14'
  spec.add_dependency 'faraday-retry', '~> 2.3'
  spec.add_dependency 'is-dsl', '~> 0.8'
  spec.add_dependency 'is-enum', '~> 0.8.8.6'
  spec.add_dependency 'is-duration', '~> 0.8.4'
  spec.add_dependency 'is-term', '~> 0.8.4.10'
  spec.add_dependency 'is-range', '~> 0.8.2'
  spec.add_dependency 'is-deep', '~> 0.8'

  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rake', '~> 13.3'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'sqlite3', '~> 2.9'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'yard-is-sequel'
  spec.add_development_dependency 'redcarpet'
end

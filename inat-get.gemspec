# frozen_string_literal: true

require_relative 'lib/inat-get/info'

Gem::Specification.new do |spec|
  spec.name = "inat-get"
  spec.version = INatGet::Info::VERSION
  spec.authors = [ INatGet::Info::AUTHOR ]
  spec.email = [ INatGet::Info::EMAIL ]

  spec.summary = "Client for iNaturalist API."
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = INatGet::Info::HOMEPAGE
  spec.license = "GPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = INatGet::Info::SOURCE_URL

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ features/ samples/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "bin"
  spec.executables = [ 'inat-get' ]
  spec.require_paths = [ "lib" ]

end

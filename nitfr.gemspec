# frozen_string_literal: true

require_relative "lib/nitfr/version"

Gem::Specification.new do |spec|
  spec.name = "nitfr"
  spec.version = NITFr::VERSION
  spec.authors = ["Mark Turner"]
  spec.email = ["mark@amerine.net"]

  spec.summary = "A Ruby gem for parsing NITF (News Industry Text Format) XML files"
  spec.description = "NITFr makes it easy for Ruby applications to parse and extract " \
                     "content from NITF XML files, the standard format used in the news industry."
  spec.homepage = "https://github.com/amerine/nitfr"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rexml"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "test-unit", "~> 3.6"
end

# frozen_string_literal: true

require_relative "lib/kml/path/version"

Gem::Specification.new do |spec|
  spec.name = "kml-path-parser"
  spec.version = Kml::Path::VERSION
  spec.authors = ["Josh McArthur"]
  spec.email = ["joshua.mcarthur@gmail.com"]

  spec.summary = "Extract paths from user-uploaded KML and KMZ files"
  spec.description = "Parse LineString and gx:Track geometry from real-world KML and KMZ exports " \
                     "(Google Earth, My Maps, and similar tools) into path names and coordinate arrays."
  spec.homepage = "https://github.com/joshmcarthur/kml-path-parser"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", ">= 1.15"
  spec.add_dependency "rubyzip", ">= 2.3"
end

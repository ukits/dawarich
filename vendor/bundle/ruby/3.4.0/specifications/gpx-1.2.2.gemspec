# -*- encoding: utf-8 -*-
# stub: gpx 1.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "gpx".freeze
  s.version = "1.2.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Guillaume Dott".freeze, "Doug Fales".freeze, "Andrew Hao".freeze]
  s.date = "1980-01-02"
  s.description = "A basic API for reading and writing GPX files.".freeze
  s.email = ["guillaume+github@dott.fr".freeze, "doug.fales@gmail.com".freeze, "andrewhao@gmail.com".freeze]
  s.homepage = "http://www.github.com/dougfales/gpx".freeze
  s.required_ruby_version = Gem::Requirement.new([">= 2.7".freeze, "< 5".freeze])
  s.rubygems_version = "4.0.3".freeze
  s.summary = "A basic API for reading and writing GPX files.".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<csv>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.7".freeze])
  s.add_runtime_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rdoc>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0".freeze])
end

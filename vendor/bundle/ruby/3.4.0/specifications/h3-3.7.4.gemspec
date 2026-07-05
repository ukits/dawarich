# -*- encoding: utf-8 -*-
# stub: h3 3.7.4 ruby lib
# stub: ext/h3/extconf.rb

Gem::Specification.new do |s|
  s.name = "h3".freeze
  s.version = "3.7.4".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sean Handley".freeze, "Xavier Noria".freeze, "Lachlan Laycock".freeze]
  s.date = "2025-04-04"
  s.email = "sean.handley@gmail.com".freeze
  s.extensions = ["ext/h3/extconf.rb".freeze]
  s.files = ["ext/h3/extconf.rb".freeze]
  s.homepage = "https://github.com/seanhandley/h3_ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.1.4".freeze
  s.summary = "C Bindings for Uber's H3 library".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<ffi>.freeze, ["~> 1.9".freeze])
  s.add_runtime_dependency(%q<rgeo-geojson>.freeze, ["~> 2.1".freeze])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.5".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.8".freeze])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9".freeze])
end

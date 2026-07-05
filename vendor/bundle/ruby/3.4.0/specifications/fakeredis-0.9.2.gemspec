# -*- encoding: utf-8 -*-
# stub: fakeredis 0.9.2 ruby lib

Gem::Specification.new do |s|
  s.name = "fakeredis".freeze
  s.version = "0.9.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Guillermo Iguaran".freeze]
  s.date = "2023-05-04"
  s.description = "Fake (In-memory) driver for redis-rb. Useful for testing environment and machines without Redis.".freeze
  s.email = ["guilleiguaran@gmail.com".freeze]
  s.homepage = "https://github.com/guilleiguaran/fakeredis".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.1".freeze
  s.summary = "Fake (In-memory) driver for redis-rb.".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<redis>.freeze, ["~> 4.8".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3".freeze])
end

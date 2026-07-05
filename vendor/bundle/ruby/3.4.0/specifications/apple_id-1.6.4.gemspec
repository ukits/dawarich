# -*- encoding: utf-8 -*-
# stub: apple_id 1.6.4 ruby lib

Gem::Specification.new do |s|
  s.name = "apple_id".freeze
  s.version = "1.6.4".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["nov".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-12-27"
  s.description = "Sign-in with Apple backend library in Ruby.".freeze
  s.email = ["nov@matake.jp".freeze]
  s.homepage = "https://github.com/nov/apple_id".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Sign-in with Apple Backend".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<json-jwt>.freeze, ["~> 1.16".freeze])
  s.add_runtime_dependency(%q<rack-oauth2>.freeze, ["~> 2.0".freeze])
  s.add_runtime_dependency(%q<openid_connect>.freeze, ["~> 2.2".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec-its>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<webmock>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
end

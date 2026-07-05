# -*- encoding: utf-8 -*-
# stub: posthog-rails 3.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "posthog-rails".freeze
  s.version = "3.14.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["PostHog".freeze]
  s.date = "1980-01-02"
  s.description = "Automatic exception tracking and instrumentation for Ruby on Rails applications using PostHog".freeze
  s.email = "engineering@posthog.com".freeze
  s.homepage = "https://github.com/PostHog/posthog-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "4.0.6".freeze
  s.summary = "PostHog integration for Rails".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<railties>.freeze, [">= 5.2.0".freeze])
  s.add_runtime_dependency(%q<posthog-ruby>.freeze, ["~> 3.14".freeze])
end

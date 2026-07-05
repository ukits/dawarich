# -*- encoding: utf-8 -*-
# stub: sidekiq-limit_fetch 4.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sidekiq-limit_fetch".freeze
  s.version = "4.4.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/deanpcmad/sidekiq-limit_fetch/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/deanpcmad/sidekiq-limit_fetch", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/deanpcmad/sidekiq-limit_fetch" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dean Perry".freeze]
  s.date = "2023-01-22"
  s.description = "Sidekiq strategy to restrict number of workers which are able to run specified queues simultaneously.".freeze
  s.email = "dean@deanpcmad.com".freeze
  s.homepage = "https://github.com/deanpcmad/sidekiq-limit_fetch".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.3".freeze
  s.summary = "Sidekiq strategy to support queue limits".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<sidekiq>.freeze, [">= 6".freeze])
  s.add_development_dependency(%q<appraisal>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<redis-namespace>.freeze, ["~> 1.5".freeze, ">= 1.5.2".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
end

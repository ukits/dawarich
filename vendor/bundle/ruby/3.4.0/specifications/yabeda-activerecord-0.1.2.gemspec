# -*- encoding: utf-8 -*-
# stub: yabeda-activerecord 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "yabeda-activerecord".freeze
  s.version = "0.1.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/yabeda-rb/yabeda-activerecord/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/yabeda-rb/yabeda-activerecord", "source_code_uri" => "https://github.com/yabeda-rb/yabeda-activerecord" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrey Novikov".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.description = "Yabeda plugin for easy collection of ActiveRecord metrics: query performance, connection pool stats, etc.\n".freeze
  s.email = ["envek@envek.name".freeze]
  s.homepage = "https://github.com/yabeda-rb/yabeda-activerecord".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Yabeda plugin to collect ActiveRecord metrics: query performance, connection pool stats, etc.".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.0".freeze])
  s.add_runtime_dependency(%q<anyway_config>.freeze, [">= 1.3".freeze, "< 3.0".freeze])
  s.add_runtime_dependency(%q<yabeda>.freeze, ["~> 0.6".freeze])
end

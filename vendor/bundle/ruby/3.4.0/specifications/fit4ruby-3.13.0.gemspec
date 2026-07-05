# -*- encoding: utf-8 -*-
# stub: fit4ruby 3.13.0 ruby lib

Gem::Specification.new do |s|
  s.name = "fit4ruby".freeze
  s.version = "3.13.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Chris Schlaeger".freeze]
  s.date = "2023-07-07"
  s.description = "This library can read and write FIT files and convert them into a Ruby data\nstructure for easy processing. This library was written for Garmin devices\nlike the FR620, Fenix 3, Fenix 3 HR, Fenix 5 (s and X). Fit files from other\ndevices may work as well but have not been tested.\n".freeze
  s.email = "chris@linux.com".freeze
  s.homepage = "https://github.com/scrapper/fit4ruby".freeze
  s.licenses = ["GNU GPL version 2".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.4.1".freeze
  s.summary = "Library to read and write GARMIN FIT files.".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<bindata>.freeze, ["~> 2.4.14".freeze])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9.28".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 2.2".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.12".freeze])
  s.add_development_dependency(%q<pry>.freeze, [">= 0.14".freeze])
end

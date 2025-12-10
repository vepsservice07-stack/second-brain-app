# -*- encoding: utf-8 -*-
# stub: packable 1.3.18 ruby lib

Gem::Specification.new do |s|
  s.name = "packable".freeze
  s.version = "1.3.18"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marc-Andr\u00E9 Lafortune".freeze]
  s.date = "2023-07-06"
  s.description = "If you need to do read and write binary data, there is of course <Array::pack and String::unpack\\n      The packable library makes (un)packing nicer, smarter and more powerful.\\n".freeze
  s.email = ["github@marc-andre.ca".freeze]
  s.homepage = "".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Extensive packing and unpacking capabilities".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<shoulda>.freeze, [">= 0"])
  s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
end

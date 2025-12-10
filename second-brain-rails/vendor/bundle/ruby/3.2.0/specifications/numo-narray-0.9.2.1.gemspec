# -*- encoding: utf-8 -*-
# stub: numo-narray 0.9.2.1 ruby lib
# stub: ext/numo/narray/extconf.rb

Gem::Specification.new do |s|
  s.name = "numo-narray".freeze
  s.version = "0.9.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Masahiro TANAKA".freeze]
  s.date = "2022-08-20"
  s.description = "Numo::NArray - New NArray class library in Ruby/Numo.".freeze
  s.email = ["masa16.tanaka@gmail.com".freeze]
  s.extensions = ["ext/numo/narray/extconf.rb".freeze]
  s.files = ["ext/numo/narray/extconf.rb".freeze]
  s.homepage = "https://github.com/ruby-numo/numo-narray".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "alpha release of Numo::NArray - New NArray class library in Ruby/Numo (NUmerical MOdule)".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, [">= 2.2.33"])
  s.add_development_dependency(%q<rake>.freeze, [">= 12.3.3"])
  s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 1.1"])
  s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
end

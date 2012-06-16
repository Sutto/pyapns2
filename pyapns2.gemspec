# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'pyapns2/version'

Gem::Specification.new do |s|
  s.name        = "pyapns2"
  s.version     = Pyapns2::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Darcy Laycock"]
  s.email       = ["darcy@filtersquad.com"]
  s.homepage    = "http://github.com/filtersquad"
  s.summary     = "An alternative ruby client for the pyapns push notification server with an emphasis on Ruby 1.9 support."
  s.description = "Pyapns2 provides an alterantive, simpler client for the pyapns push notification server, using libxml-xmlrpc to handle all of the  xmlrpc.\nIt also is tested against Ruby 1.9"
  s.required_rubygems_version = ">= 1.3.6"
  
  s.add_dependency 'libxml-xmlrpc'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec',       '~> 2.4'
  s.add_development_dependency 'rr',          '~> 1.0'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'vcr'
  
  s.files        = Dir.glob("{lib}/**/*")
  s.require_path = 'lib'
end
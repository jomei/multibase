# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multibase/version'

Gem::Specification.new do |spec|
  spec.name        = 'multibase'
  spec.version     = Multibase::VERSION
  spec.authors     = ['Anatoly Nosov']
  spec.email       = ['jomeisama@gmail.com']

  spec.summary     = %q{Rails multiple database support}
  spec.description = 'Multibase provides support for Rails to manage several databases by extending ActiveRecord tasks that create, migrate, and test your databases.'
  spec.homepage    = 'https://github.com/jomei/multibase'
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']

  spec.add_runtime_dependency     'rails', '>= 4.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pg'
end

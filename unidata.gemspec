# -*- encoding: utf-8 -*-
require File.expand_path('../lib/unidata/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "unidata"
  gem.version       = Unidata::VERSION
  gem.authors       = ["Jeremy Israelsen"]
  gem.email         = ["jisraelsen@gmail.com"]
  gem.homepage      = "http://github.com/jisraelsen/unidata"
  gem.description   = %q{A simple ORM for Rocket's UniData database}
  gem.summary       = %q{A simple ORM for Rocket's UniData database}

  gem.files         = `git ls-files -- lib/*`.split("\n") + %w[LICENSE README.md]
  gem.test_files    = `git ls-files -- spec/*`.split("\n")
  gem.require_path  = 'lib'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec',     '~> 2.10'
  gem.add_development_dependency 'simplecov', '~> 0.6'
end

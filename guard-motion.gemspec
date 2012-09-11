# -*- encoding: utf-8 -*-
require File.expand_path('../lib/guard/motion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["mordaroso"]
  gem.email         = ["mordaroso@gmail.com"]
  gem.homepage      = 'http://rubygems.org/gems/guard-motion'
  gem.summary       = 'Guard gem for RubyMotion'
  gem.description   = 'Guard::Motion automatically run your specs (much like autotest).'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "guard-motion"
  gem.require_paths = ["lib"]
  gem.version       = Guard::MotionVersion::VERSION

  gem.add_dependency 'guard', '>= 1.1.0'
  gem.add_dependency 'rake',  '>= 0.9'

  gem.add_development_dependency 'bundler',       '>= 1.1.0'
  gem.add_development_dependency 'rspec',         '~> 2.10'
  gem.add_development_dependency 'guard-rspec',   '~> 1.1'
end

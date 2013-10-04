# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake/notes/version'

Gem::Specification.new do |gem|
  gem.name          = "rake-notes"
  gem.version       = Rake::Notes::VERSION
  gem.authors       = ["Fabio Rehm"]
  gem.email         = ["fgrehm@gmail.com"]
  gem.description   = "rake notes task for non-Rails' projects"
  gem.summary       = "rake notes task for non-Rails' projects"
  gem.homepage      = "https://github.com/fgrehm/rake-notes"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'rake'
  gem.add_dependency 'colored'

  gem.add_development_dependency 'rspec'
end

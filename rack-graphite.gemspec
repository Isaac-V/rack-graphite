# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/graphite/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-graphite"
  spec.version       = Rack::Graphite::VERSION
  spec.authors       = ["R. Tyler Croy"]
  spec.email         = ["rtyler.croy@lookout.com"]
  spec.description   = "Simple Rack middleware for logging request counts/timing information"
  spec.summary       = "Simple Rack middleware for logging request counts/timing information"
  spec.homepage      = "https://github.com/lookout/rack-graphite"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"

  spec.add_dependency 'lookout-statsd', '~> 3.0'
end

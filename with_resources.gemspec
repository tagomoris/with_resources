# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'with_resources/version'

Gem::Specification.new do |spec|
  spec.name          = "with_resources"
  spec.version       = WithResources::VERSION
  spec.authors       = ["TAGOMORI Satoshi"]
  spec.email         = ["tagomoris@gmail.com"]

  spec.summary       = %q{Introduce "with" statement.}
  spec.description   = %q{The library to provide "with" statement to allocate and release resources safely.}
  spec.homepage      = "https://github.com/tagomoris/with_resources"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lxcos/runner/version'

Gem::Specification.new do |spec|
  spec.name          = "lxcos-runner"
  spec.version       = Lxcos::Runner::VERSION
  spec.authors       = ["Axelerant"]
  spec.email         = ["devaroop@yahoo.co.in"]
  spec.summary       = %q{lxcos container management}
  spec.description   = %q{lxcos container management}
  spec.homepage      = "http://axelerant.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "log4r"
  spec.add_runtime_dependency "chef", "~> 11.6.2"
  spec.add_runtime_dependency "net-ssh"
  spec.add_runtime_dependency "lxc"
  spec.add_runtime_dependency "knife-ec2"
  spec.add_runtime_dependency "route53"
  spec.add_runtime_dependency "capistrano", "~> 3.2.1"
end

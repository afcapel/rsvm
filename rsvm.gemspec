# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "svm/version"

Gem::Specification.new do |s|
  s.name        = "rsvm"
  s.version     = Svm::VERSION
  s.authors     = ["Alberto Fernández Capel"]
  s.email       = ["afcapel@gmail.com"]
  s.homepage    = ""
  s.summary     = "Support Vector Machine Gem"
  s.description = "FFI Ruby wrapper around libsvm"

  s.rubyforge_project = "rsvm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "ffi"
  
  s.extensions << 'ext/libsvm/extconf.rb'
end

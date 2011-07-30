# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "stepper/version"

Gem::Specification.new do |s|
  s.name        = "stepper"
  s.version     = Stepper::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sujimichi"]
  s.email       = ["sujimichi@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Cucumber Step definition search tool}
  s.description = %q{Command line tool which can locate step definitions used in cucumber features, determine which step definitions are not being used and for each step definition list the feature steps which use it.}

  s.add_development_dependency('rspec')
  s.add_development_dependency('ZenTest')


  s.rubyforge_project = "stepper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.bindir = 'bin'
end

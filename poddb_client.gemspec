# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "poddb_client/version"

Gem::Specification.new do |s|
  s.name        = "poddb_client"
  s.version     = PoddbClient::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.6'

  s.authors     = ["Daniel Choi"]
  s.email       = ["dhchoi@gmail.com"]
  s.homepage    = "http://danielchoi.com/software/poddb.html"
  s.summary     = %q{Podcast aggregation from the command line}
  s.description = %q{Podcast aggregation from the command line}

  s.rubyforge_project = "poddb_client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  message = "** Now please run poddb_client-install to install the Vim plugin **"
  divider = "*" * message.length 
  s.post_install_message = [divider, message, divider].join("\n")
end


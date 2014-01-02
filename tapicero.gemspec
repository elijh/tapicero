$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tapicero/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tapicero"
  s.version     = Tapicero::VERSION
  s.authors     = ["Azul"]
  s.email       = ["azul@leap.se"]
  s.homepage    = "https://leap.se"
  s.summary     = "Tapicero - create per user databases for the LEAP Platform"
  s.description = "Watches the couch database for users and creates per user databases when new users are created. This way soledad and the leap webapp do not need admin privileges required to create databases."

  s.files = Dir["{config,lib}/**/*", 'bin/*'] + ["Rakefile", "Readme.md"]
  s.test_files = Dir["test/**/*"]
  s.bindir = 'bin'
  s.executables << 'tapicero'

  s.add_dependency "couchrest", "~> 1.1.3"
  s.add_dependency "couchrest_changes", "~> 0.0.5"
  s.add_dependency "daemons"
  s.add_dependency "yajl-ruby", "~> 1.1.0"
  s.add_dependency "syslog_logger", "~> 2.0.0"
  s.add_development_dependency "minitest", "~> 3.2.0"
  s.add_development_dependency "mocha"
  s.add_development_dependency "rake"
  s.add_development_dependency "highline"
end

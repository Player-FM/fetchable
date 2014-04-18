$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fetchable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|

  s.name        = "fetchable"
  s.version     = Fetchable::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Fetchable."
  s.description = "TODO: Description of Fetchable."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.0"
  s.add_dependency "hashie"
  s.add_dependency "excon"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "addressable"
  s.add_development_dependency "byebug"
  s.add_development_dependency "single_test"
  s.add_development_dependency "timecop"

end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fetchery/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|

  s.name        = "fetchery"
  s.version     = Fetchery::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Fetchery."
  s.description = "TODO: Description of Fetchery."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.0"
  %w(hashie excon)
  .each { |lib| s.add_dependency lib }

  %w(sqlite3 addressable byebug single_test timecop mocha)
  .each { |lib| s.add_development_dependency lib }

end

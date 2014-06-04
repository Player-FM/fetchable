$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fetchable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|

  s.name        = "fetchable"
  s.version     = Fetchable::VERSION
  s.authors     = ["Michael Mahemoff"]
  s.email       = ["michael@mahemoff.com"]
  s.homepage    = "https://mahemoff.com"
  s.summary     = "Sync your active records with remote resources"
  s.description = "By including acts_as_fetchable in your model, you can run a fetch command which will download content specified by the model's 'url' property. The content and call data will be stored and events will be triggered throughout the fetch lifecycle (e.g. after_fetch_error). Support for scheduling recurring fetches is provided."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.0"
  s.add_dependency "hashie", "~> 2.0.0"
  s.add_dependency "excon", "~> 0.33.0"

  %w(sqlite3 addressable byebug single_test timecop mocha)
  .each { |lib| s.add_development_dependency lib }

end

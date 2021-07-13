Gem::Specification.new do |gem|
  gem.name          = "shrine-url"
  gem.version       = "2.4.0"

  gem.required_ruby_version = ">= 2.1"

  gem.summary      = "Provides a fake storage which allows you to create a Shrine attachment defined only by a custom URL."
  gem.homepage     = "https://github.com/shrinerb/shrine-url"
  gem.authors      = ["Janko Marohnić"]
  gem.email        = ["janko.marohnic@gmail.com"]
  gem.license      = "MIT"

  gem.files        = Dir["README.md", "LICENSE.txt", "lib/**/*.rb", "*.gemspec"]
  gem.require_path = "lib"

  gem.add_dependency "shrine", ">= 3.0.0.rc", "< 4"
  gem.add_dependency "down", "~> 5.0"
  gem.add_dependency "http", ">= 3.2", "< 6"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "docker-api"
  gem.add_development_dependency "posix-spawn" unless RUBY_ENGINE == "jruby"
end

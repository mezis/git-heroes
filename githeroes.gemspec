# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_heroes/version'

Gem::Specification.new do |spec|
  spec.name          = "git-heroes"
  spec.version       = GitHeroes::VERSION
  spec.authors       = ["Julien Letessier"]
  spec.email         = ["julien.letessier@gmail.com"]
  spec.description   = %q{Leaderboard of your team's Github activity}
  spec.summary       = %q{Leaderboard of your team's Github activity}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "octokit"
  spec.add_dependency "dotenv"
  spec.add_dependency "redis-activesupport"
  spec.add_dependency "faraday-http-cache"
  spec.add_dependency "redis"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
end

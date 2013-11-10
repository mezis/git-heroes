require 'git_heroes'
require 'logger'
require 'delegate'
require 'singleton'

class GitHeroes::Logger < SimpleDelegator
  include Singleton

  def initialize
    logger = ::Logger.new($stderr)
    super(logger)
  end
end
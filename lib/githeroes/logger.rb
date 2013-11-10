require 'githeroes'
require 'logger'
require 'delegate'
require 'singleton'

class Githeroes::Logger < SimpleDelegator
  include Singleton

  def initialize
    logger = ::Logger.new($stderr)
    super(logger)
  end
end
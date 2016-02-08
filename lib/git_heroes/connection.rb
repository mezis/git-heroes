require 'delegate'
require 'octokit'
require 'git_heroes'
require 'git_heroes/cache'
require 'git_heroes/logger'
require 'git_heroes/serializer'
require 'git_heroes/ext/faraday'

require 'redis/store'
require 'active_support'

class GitHeroes::Connection < SimpleDelegator
  def initialize(token:nil)
    stack = Faraday::Builder.new do |builder|
      builder.use(:http_cache,
        store:         ActiveSupport::Cache.lookup_store(:redis_store, %w(localhost/0/githeroes)),
        # store:         :redis_store,
        # store_options: %w(localhost/0/githeroes),
        serializer:    GitHeroes::Serializer,
        logger:        GitHeroes::Logger.instance)
      builder.use     GitHeroes::Cache
      builder.use     Octokit::Response::RaiseError
      # builder.adapter Faraday.default_adapter
      builder.adapter :net_http_persistent
    end

    client = Octokit::Client.new(
      access_token: token,
      middleware:   stack)

    super(client)
  end
end

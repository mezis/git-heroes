require 'delegate'
require 'octokit'
require 'githeroes'
require 'githeroes/cache'
require 'githeroes/logger'
require 'githeroes/serializer'
require 'githeroes/ext/faraday'

class Githeroes::Connection < SimpleDelegator
  def initialize(token:nil)
    stack = Faraday::Builder.new do |builder|
      builder.use(:http_cache,
        store:         :redis_store,
        store_options: %w(localhost/0/githeroes),
        serializer:    Githeroes::Serializer,
        logger:        Githeroes::Logger.instance)
      builder.use     Githeroes::Cache
      builder.use     Octokit::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end

    client = Octokit::Client.new(
      access_token: token,
      middleware:   stack)

    super(client)
  end
end
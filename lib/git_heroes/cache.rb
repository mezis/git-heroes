require 'git_heroes'
require 'faraday'

class GitHeroes::Cache < Faraday::Middleware
  def call(env, *args)
    # do something with the request
    force_cache = !! env[:request_headers]['X-Force-Cache']

    @app.call(env).on_complete do |response|
      # do something with the response
      if force_cache
        response[:response_headers]['cache-control'] = 'public, max-age=31536000'
      end
    end
  end
end
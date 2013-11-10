# Monkey-patch Faraday cache
# Forces long caching, even for private resources
Faraday::HttpCache::CacheControl.class_eval do
  def private?
    false
  end

  def shared_max_age
    36000
  end
end

$REDIS_CONNECTION_POOL = ConnectionPool.new(size: Rails.application.config.redis.pool_size,
                                            timeout: Rails.application.config.redis.pool_size) do
  Redis.new(url: Rails.application.config.redis.url)
end

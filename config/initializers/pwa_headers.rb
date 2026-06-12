# PWA-specific cache headers
#
# Service workers and manifests MUST be served with a no-cache header,
# otherwise the browser keeps using a stale SW and the install banner
# may never appear. Rails' default in development caches public files
# for 2 days (config/environments/development.rb#public_file_server.headers)
# — this middleware overrides that for PWA-critical files in ALL envs.
class PwaCacheHeaders
  # Anything in this list gets a no-cache header so the browser always
  # re-validates with the server. PWA install + update logic depends on it.
  PATHS = %w[
    /service-worker.js
    /manifest.json
    /offline.html
  ].freeze

  NO_CACHE = { "cache-control" => "no-cache, no-store, must-revalidate" }.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    if PATHS.include?(env["PATH_INFO"])
      headers = headers.merge(NO_CACHE)
    end
    [status, headers, body]
  end
end

# Insert the middleware early so it can patch the response before
# other middleware (e.g. ETag) writes headers.
Rails.application.config.middleware.insert_before(
  Rack::ETag,
  PwaCacheHeaders
)

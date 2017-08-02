require 'faraday'
require 'opentracing'

class FaradayTraceMiddleware < Faraday::Middleware
  def call(env)
    span = OpenTracing.start_span("my_span")
    OpenTracing.inject(span.context, OpenTracing::FORMAT_RACK, env)
    @app.call(env).on_complete do
      span.finish
    end
  end
end

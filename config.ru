#use Rack::Lint # gives more descriptive error messages when responses aren't valid
require "rubygems"
require "sinatra"
require 'opentracing'
require 'zipkin/tracer'
require 'faraday'

require File.expand_path '../app_mw.rb', __FILE__

class TraceMiddleware

  attr_accessor :master_span_context, :master_span, :child_span, :count

  def initialize(app)
    @app = app
    OpenTracing.global_tracer = Zipkin::Tracer.build(url: 'http://localhost:9411', service_name: 'ruby_app')
    puts 'OpenTracing initialized!'
    @count = 0
  end
  def call(env)
    puts 'A call has been intercepted!'
    req = Rack::Request.new(env)
    if @master_span.nil?
      puts 'master_span is NULL!'
      #@master_span_context = OpenTracing.global_tracer.extract(OpenTracing::FORMAT_RACK, env)
      #OpenTracing.inject(@master_span_context, OpenTracing::FORMAT_RACK, env)
      @master_span = OpenTracing.start_span(req.path_info)
      @count = 0
      puts 'doing the call for MASTER_SPAN...'
      status, headers, body = @app.call(env)
      puts 'call for MASTER_SPAN done!!'
      puts 'FINISHING MASTER_SPAN!'
      @master_span.finish
      @master_span = nil
      [status, headers, body]
    else
      puts 'master_span EXISTS!'
      puts 'creating a CHILD_SPAN!'

      @child_span = OpenTracing.start_span(req.path_info, child_of: @master_span)
      @count += 1

      puts 'doing the call...'
      status, headers, body = @app.call(env)
      puts 'call done!!'

      if(@count > 0)
        puts 'FINISHING CHILD_SPAN!'
        @child_span.finish
        @count -= 1
      else
        puts 'FINISHING MASTER_SPAN!'
        @master_span.finish
        @master_span = nil
      end

      puts 'SPAN SHIT DONE!'
      [status, headers, body]
    end
  end
end

use TraceMiddleware
run App

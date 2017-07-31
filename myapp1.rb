# myapp1.rb
require 'sinatra'
require 'opentracing'


#span = OpenTracing.start_span("operation_name")
#span.finish

set :bind, '0.0.0.0'
OpenTracing.global_tracer = OpenTracing::Tracer.new

get '/demora0' do
  "Hello World #{params[:oi]}".strip
end

get '/demora3' do
  puts "antes"
  span = OpenTracing.start_span("oi1")
  sleep 3
  span.finish
  puts "depois"
  "Demorou 3 #{params[:oi]}".strip
end

get '/oi2' do
  "Hello World #{params[:oi]}".strip
end

get '/oi3' do
  "Hello World #{params[:oi]}".strip
end

# myapp1.rb
require 'sinatra'
require 'opentracing'
require 'zipkin/tracer'
require 'faraday'


# Install rvm
# install ruby 2.3.0
# gem install bundler


set :bind, '0.0.0.0'
OpenTracing.global_tracer = Zipkin::Tracer.build(url: 'http://localhost:9411', service_name: 'ruby_app')

#-------------------------------------------------------
myspam = nil
mysubspam = nil
count = 0

before do
  if myspam.nil?
    count = 0
    myspam = OpenTracing.start_span(request.path_info)
  else
    mysubspam = OpenTracing.start_span(request.path_info, child_of: myspam)
    count += 1
  end
end
after do
  if(count > 0)
    mysubspam.finish
    count -= 1
  else
    myspam.finish
  end
end
#--------------------------------------------------------

get '/demora0' do
  "Hello World #{params[:data]}".strip
end

get '/demora3' do
  puts "[demora3] antes"
  sleep 3
  ret = "Demorou 3 #{params[:data]}".strip
  puts "[demora3] depois"
  ret
end

get '/demora5' do
  puts "[demora5] antes"
  sleep 5
  ret = "Demorou 5 #{params[:data]}".strip
  puts "[demora5] depois"
  ret
end

get '/demora7' do
  puts "[demora7] antes"
  sleep 7
  ret = "Demorou 7 #{params[:data]}".strip
  puts "[demora7] depois"
  ret
end

get '/demora15' do
  puts "[demora15] antes"
  r3 = Faraday.get 'http://localhost:4567/demora3?data=oi3'
  r5 = Faraday.get 'http://localhost:4567/demora5?data=oi5'
  r7 = Faraday.get 'http://localhost:4567/demora7?data=oi7'
  ret = "#{r3.body}/#{r5.body}/#{r7.body} Demorou 15 no total"
  puts "[demora15] depois"
  ret
end

# myapp1.rb
require 'sinatra'
require 'opentracing'
require 'zipkin/tracer'
require 'faraday'


# Install rvm
# install ruby 2.3.0
# gem install bundler

class App < Sinatra::Application
  #set :bind, '0.0.0.0'
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
end

#-------------------------------------------------------
#--------------------------------------------------------

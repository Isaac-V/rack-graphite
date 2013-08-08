$LOAD_PATH.unshift(File.expand_path(__FILE__ + '/../lib'))

require 'rack/graphite'
require 'rack/test'

unless RUBY_PLATFORM == 'java'
  # Only require the debugger on MRI
  require 'debugger'
  require 'debugger/pry'
end

RSpec.configure do |c|
  c.include(Rack::Test::Methods, :type => :integration)
  c.before(:all, :type => :integration) do
  end
end


require 'sinatra/base'
class TestApp < Sinatra::Base
  use Rack::Graphite

  get '/' do
    'Hello'
  end

  put '/onelevel' do
    'Thanks'
  end

  get '/onelevel' do
    'Hello One Level'
  end

  get '/two/levels' do
    'Hello Two Levels'
  end
end

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
    require 'sinatra/base'
  end
end

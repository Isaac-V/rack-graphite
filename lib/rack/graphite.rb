require 'statsd'

module Rack
  class Graphite
    VERSION = '1.0.0'

    def initialize(app, options={})
      @app = app
    end

    def call(env)
      Statsd.instance.timing('foo') do
        @app.call(env)
      end
    end

  end
end

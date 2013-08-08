require 'statsd'

module Rack
  class Graphite
    VERSION = '1.0.0'
    PREFIX = 'requests'

    def initialize(app, options={})
      @app = app
      @prefix = options[:prefix] || PREFIX
    end

    def call(env)
      path = env['PATH_INFO'] || '/'
      method = env['REQUEST_METHOD'] || 'GET'
      metric = path_to_graphite(method, path)

      result = nil
      Statsd.instance.timing(metric) do
        result = @app.call(env)
      end
      return result
    end

    def path_to_graphite(method, path)
      method = method.downcase
      if (path.nil?) || (path == '/') || (path.empty?)
        "#{@prefix}.#{method}.root"
      else
        path = path.gsub('/', '.')
        "#{@prefix}.#{method}#{path}"
      end
    end
  end
end

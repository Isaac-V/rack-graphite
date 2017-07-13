rack-graphite
=============

Rack middleware for automatically logging request information to Graphite.


This gem assumes that you're using
[lookout-statsd](https://github.com/lookout/statsd) and have already initalized
`Lookout::Statsd.instance` in your environment before handling any requests.

By default this will log metrics such as:

* For a `GET /` request
    * `requests.get.root.`
        * `count`
        * `lower`
        * `mean`
        * `upper`
        * `upper_90`
* For a `GET /home` request
    * `requests.get.home.`
        * `count`
        * `lower`
        * `mean`
        * `upper`
        * `upper_90`
* For a `PUT /upload' request
    * `requests.put.upload.`
        * `count`
        * `lower`
        * `mean`
        * `upper`
        * `upper_90`
* For a `GET /user/login` request
    * `requests.get.user.login.`
        * `count`
        * `lower`
        * `mean`
        * `upper`
        * `upper_90`

## Usage

**In Sinatra**

    require 'rack/graphite'

    class MyApp < Sinatra::Base
      use Rack::Graphite

      get '/' do
        'Hello!'
      end
    end
    
Filter options have been added as an initialization parameter allowing 
specific requests not be processed by [lookout-statsd](https://github.com/lookout/statsd). 
The filter option is assumed to be a list of lambda functions that will be
applied to rack requests. An example of initializing rack-graphite with a
filter option is provided below:


    require 'rack/graphite'

    class MyApp < Sinatra::Base
      use Rack::Graphite, { filters: [ lambda{|env| env['PATH_INFO'].include? 'dont_log'} ] }

      get '/' do
        'Hello!'
      end
      
      get "/dont_log/#{random_number}" do
        'Causes too many metrics.'
      end
    end
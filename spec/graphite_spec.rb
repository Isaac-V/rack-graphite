require 'spec_helper'
require 'securerandom'

describe Rack::Graphite do
  let(:statsd) { double('Mock Lookout::StatsdClient') }

  before :each do
    Lookout::Statsd.stub(:instance).and_return(statsd)
  end


  describe '#path_to_graphite' do
    let(:middleware) { described_class.new(nil) }
    let(:guid) { SecureRandom.uuid }
    subject(:graphite) { middleware.path_to_graphite(method, path) }

    context 'GET requests' do
      let(:method) { 'GET' }

      context 'with a / URL' do
        let(:path) { '/' }
        it { should eql('requests.get.root') }
      end

      context 'with a onelevel URL' do
        let(:path) { '/onelevel' }
        it { should eql('requests.get.onelevel') }
      end

      context 'with a twolevel URL' do
        let(:path) { '/two/level' }
        it { should eql('requests.get.two.level') }
      end

      context 'with an empty URL' do
        let(:path) { '' }
        it { should eql('requests.get.root') }
      end

      context 'with a nil URL' do
        let(:path) { nil }
        it { should eql('requests.get.root') }
      end

      context 'with an id embedded in a path' do
        let(:path) { '/one/234/five' }
        it { should eql('requests.get.one.id.five') }
      end

      context 'with a path ending in an id' do
        let(:path) { '/one/234' }
        it { should eql('requests.get.one.id') }
      end

      context 'with a alpha-numeric in a path' do
        let(:path) { '/one/v1/two' }
        it { should eql('requests.get.one.v1.two') }
      end

      context 'with a guid embedded in a path with slashes' do
        let(:path) { "/one/#{guid}/five" }
        it { should eql('requests.get.one.guid.five') }
      end

      context 'with a guid embedded in a path without slashes' do
        let(:path) { "/one_#{guid}_one/five" }
        it { should eql('requests.get.one_guid_one.five') }
      end

      context 'with a path ending in a guid' do
        let(:path) { "/one/#{guid}" }
        it { should eql('requests.get.one.guid') }
      end

      context 'with something close to a guid in a path' do
        let(:path) { '/one/deadbeef-babe-cafe/two' }
        it { should eql('requests.get.one.deadbeef-babe-cafe.two') }
      end
    end
  end


  context 'with a fake app' do
    let(:app) { double('Mock Rack App') }
    let(:status) { 200 }
    let(:headers) { {:foo => 'bar' } }
    let(:response) { double('Mock Response') }
    subject(:middleware) { described_class.new(app) }

    before :each do
      # Stub out time by default to and just yield
      statsd.stub(:time).and_yield
      statsd.stub(:increment)
    end

    describe '#call' do
      let(:env) { {:test => 'rspec'} }

      before :each do
        # Stub out by default for all tests
        app.stub(:call).and_return([status, headers, response])
      end

      it 'should propogate the invocation to the app' do
        app.should_receive(:call).with(env)
        middleware.call(env)
      end

      it 'should return response of the app' do
      end

      it 'should return the result of the propogated app.call' do
        expect(middleware.call(env)).to eql([status, headers, response])
      end

      it 'should invoke a timer' do
        statsd.should_receive(:time)
        middleware.call({})
      end

      context 'with a filtered request' do
        let(:middleware) { described_class.new(app, {filters: [ lambda {|req| req['PATH_INFO'].include? 'onelevel'} ]}) }
        let(:env) { {'PATH_INFO' => '/onelevel'} }

        it 'does not invoke Lookout::Statsd' do
          statsd.should_not_receive(:time)
          statsd.should_not_receive(:increment)
          expect(middleware.call(env)).to eql([status, headers, response])
        end
      end
    end
  end

  context 'with a simple Sinatra app', :type => :integration do
    let(:app) { TestApp }

    subject(:response) { last_response }

    context 'with a root request' do
      before :each do
        statsd.should_receive(:time).with('requests.get.root').and_yield
        statsd.should_receive(:increment).with('requests.get.root.response.200')
        get '/'
      end
      its(:status) { should eql(200) }
    end

    context 'with a request with query params' do
      before :each do
        statsd.should_receive(:time).with('requests.get.onelevel').and_yield
        statsd.should_receive(:increment).with('requests.get.onelevel.response.200')
        get '/onelevel?q=foo'
      end
      its(:status) { should eql(200) }
    end

    context 'with a PUT request' do
      before :each do
        statsd.should_receive(:time).with('requests.put.onelevel').and_yield
        statsd.should_receive(:increment).with('requests.put.onelevel.response.200')
        put '/onelevel'
      end
      its(:status) { should eql(200) }
    end
  end
end

require 'spec_helper'

describe Rack::Graphite do
  let(:statsd) { double('Mock Statsd::Client') }

  before :each do
    Statsd.stub(:instance).and_return(statsd)
  end


  describe '#path_to_graphite' do
    let(:middleware) { described_class.new(nil) }
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
    end
  end


  context 'with a fake app' do
    let(:app) { double('Mock Rack App') }
    subject(:middleware) { described_class.new(app) }

    before :each do
      # Stub out timing by default to and just yield
      statsd.stub(:timing).and_yield
    end

    describe '#call' do
      let(:env) { {:test => 'rspec'} }

      before :each do
        # Stub out by default for all tests
        app.stub(:call)
      end

      it 'should propogate the invocation to the app' do
        app.should_receive(:call).with(env)
        middleware.call(env)
      end

      it 'should return the result of the propogated app.call' do
        result = double('Mock Rack Response')
        app.should_receive(:call).and_return(result)
        expect(middleware.call({})).to eql(result)
      end

      it 'should invoke a timer' do
        statsd.should_receive(:timing)
        middleware.call({})
      end
    end
  end

  context 'with a simple Sinatra app', :type => :integration do
    let(:app) { TestApp }

    subject(:response) { last_response }

    context 'with a root request' do
      before :each do
        statsd.should_receive(:timing).with('requests.get.root').and_yield
        get '/'
      end
      its(:status) { should eql(200) }
    end

    context 'with a request with query params' do
      before :each do
        statsd.should_receive(:timing).with('requests.get.onelevel').and_yield
        get '/onelevel?q=foo'
      end
      its(:status) { should eql(200) }
    end

    context 'with a PUT request' do
      before :each do
        statsd.should_receive(:timing).with('requests.put.onelevel').and_yield
        put '/onelevel'
      end
      its(:status) { should eql(200) }
    end
  end
end

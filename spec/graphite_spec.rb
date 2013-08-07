require 'spec_helper'

describe Rack::Graphite do
  let(:statsd) { double('Mock Statsd::Client') }

  before :each do
    Statsd.stub(:instance).and_return(statsd)
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
        expect(middleware.call(nil)).to eql(result)
      end

      it 'should invoke a timer' do
        statsd.should_receive(:timing)
        middleware.call(nil)
      end
    end
  end

  context 'with a simple Sinatra app', :type => :integration do
    let(:app) do
      class TestApp < Sinatra::Base
        use Rack::Graphite

        get '/' do
          'Hello'
        end
      end

      TestApp
    end

    subject(:response) { last_response }

    context 'with graphites' do
      before :each do
        statsd.should_receive(:timing).and_yield
        get '/'
      end

      its(:status) { should eql(200) }
    end
  end
end

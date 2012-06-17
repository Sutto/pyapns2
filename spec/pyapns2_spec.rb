require 'spec_helper'

describe Pyapns2 do

  use_vcr_cassette

  let(:config)  { TestConfiguration.instance }
  let(:app)     { config.fake_app }
  let(:options) { config.provisioning_options }
  let(:client)  { Pyapns2.new config.host, config.port }

  describe 'provisioning' do

    it 'should raise an argument error with an invalid app_id' do
      expect { client.provision options.merge(app_id: nil) }.to raise_error ArgumentError
      expect { client.provision options.merge(app_id: "") }.to raise_error ArgumentError
      expect { client.provision options.merge(app_id: 123) }.to raise_error ArgumentError
    end

    it 'should raise an argument error with an invalid cert' do
      expect { client.provision options.merge(cert: nil) }.to raise_error ArgumentError
      expect { client.provision options.merge(cert: "") }.to raise_error ArgumentError
      expect { client.provision options.merge(cert: 123) }.to raise_error ArgumentError
    end

    it 'should raise an argument error with an invalid timeout' do
      expect { client.provision options.merge(timeout: nil) }.to raise_error ArgumentError
      expect { client.provision options.merge(timeout: "10") }.to raise_error ArgumentError
      expect { client.provision options.merge(timeout: -10) }.to raise_error ArgumentError
    end

    it 'should raise an argument error with an invalid environment' do
      expect { client.provision options.merge(env: nil) }.to raise_error ArgumentError
      expect { client.provision options.merge(env: "awesome") }.to raise_error ArgumentError
      expect { client.provision options.merge(env: "staging") }.to raise_error ArgumentError
      expect { client.provision options.merge(env: 1) }.to raise_error ArgumentError
    end

    context 'hitting the server' do

      it 'should return true' do
        client.provision(options).should be_true
      end

    end

  end

  describe 'notifying a user' do

    let(:token)        { config.token }
    let(:notification) { {aps: {alert: "Hello from tests!"}} }

    before :each do
      # Provision a client that we're able to use to send notifications.
      client.provision options
    end

    it 'should raise an error with an invalid app_id' do
      expect do
        client.notify 'this-is-a-fake-app', token, notification
      end.to raise_error Pyapns2::Error
    end

    it 'should raise an error with invalid tokens' do
      expect { client.notify app, nil, notification }.to raise_error ArgumentError
      expect { client.notify app, 123, notification }.to raise_error ArgumentError
    end

    it 'should raise an error with invalid notifications' do
      expect { client.notify app, token, nil }.to raise_error ArgumentError
      expect { client.notify app, token, "test-notification" }.to raise_error ArgumentError
    end

    it 'should raise an error with mismatched types' do
      expect { client.notify app, [token], notification }.to raise_error ArgumentError
      expect { client.notify app, token, [notification] }.to raise_error ArgumentError
    end

    context 'hitting the server' do

      it 'should raise an exception if notifications fail' do
        expect { client.notify 'non-existing-app', token, notification }.to raise_error Pyapns2::Error
        expect { client.notify app, ("a" * 5), notification }.to raise_error Pyapns2::Error
      end

      it 'should return true if the notification works' do
        client.notify(app, token, notification).should be_true
      end

      it 'should work with a hash' do
        client.notify app, token => notification
      end

      it 'should work with a single notification' do
        client.notify app, token, notification
      end

      it 'should work with an array' do
        client.notify app, [token], [notification]
      end

    end

  end

  describe 'getting feedback' do

    it 'should raise an error with an invalid app_id' do
      expect { client.feedback nil }.to raise_error ArgumentError
    end

    context 'htting the server' do

      it 'should correctly return an array' do
        client.feedback(app).should be_a Array
      end

      it 'should return the error with an invalid app id' do
        expect { client.feedback 1 }.to raise_error Pyapns2::Error
        expect { client.feedback "unknown-app-id" }.to raise_error Pyapns2::Error
        expect { client.feedback "id" }.to raise_error Pyapns2::Error
      end

    end

  end

end
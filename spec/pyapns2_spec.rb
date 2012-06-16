require 'spec_helper'

describe Pyapns2 do

  let(:config) { TestConfiguration.instance }

  let(:options) { config.provisioning_options }
  let(:client)  { Pyapns2.new config.host, config.port }

  describe 'provisioning' do

    it 'should raise an argument error with an invalid app_id' do
      expect { client.provision options.merge(app_id: nil) }.to raise_error ArgumentError
      expect { client.provision options.merge(app_id: "") }.to raise_error ArgumentError
      expect { client.provision options.merge(app_id: 123) }.to raise_error ArgumentError
    end

    it 'should raise an argument error with an invalid cert'

    it 'should raise an argument error with an invalid timeout'

    it 'should raise an argument error with an invalid environment'

    context 'hitting the server' do

      it 'should return true'

    end

  end

  describe 'notifying a user' do

    it 'should raise an error with an invalid app_id'

    it 'should raise an error with invalid tokens'

    it 'should raise an error with invalid notifications'

    it 'should raise an error with mismatched types'

    context 'hitting the server' do

      it 'should raise an exception if notifications fail'

      it 'should return true if the notification works'

      it 'should work with a hash'

      it 'should work with a single notification'

      it 'should work with an array'

      it 'should return the error with an unknown app_id'

    end

  end

  describe 'getting feedback' do

    it 'should raise an error with an invalid app_id'

    context 'htting the server' do

      it 'should correctly return an array'

      it 'should return the error with an invalid app id'

    end

  end

end
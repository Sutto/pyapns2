$LOAD_PATH.unshift Pathname(__FILE__).dirname.dirname.join("lib").to_s

require 'webmock'
require 'vcr'
require 'rr'

require 'pyapns2'

require 'singleton'
class TestConfiguration

  include Singleton

  attr_reader :host, :port, :token, :cert_path, :fake_app

  def initialize
    fake_token = (1..64).map { |t| rand(16).to_s(16) }.join
    self.host = (ENV['PYAPNS_HOST'] || 'localhost')
    self.port = (ENV['PYAPNS_PORT'] || 7077).to_i
    self.token = (ENV['TEST_PUSH_TOKEN'] || fake_token)
    self.cert_path = File.expand_path "../certificates/#{(ENV['PYAPNS_CERT'] || "fake")}.pem", __FILE__
    self.fake_app = "fake-app-#{Time.now.to_i}"
  end

  def cert
    @cert ||= File.read(cert_path)
  end

  def provisioning_options
    {
      app_id:      app_id,
      cert:        cert,
      environment: 'sandbox',
      timeout:     15
    }
  end

end

p $pyapns_default_options

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {:record => :new_episodes}
  # Filter out parts of the test
  config = TestConfiguration.instance
  %w(pyapns_host pyapns_port notification_token pyapns_fake_app).each do |var_name|
    c.filter_sensitive_data("{#{var_name}}") { config.send var_name }
  end
end

RSpec.configure do |config|
  config.mock_with :rr
end
require 'net/http'
require 'xml/libxml/xmlrpc'

class Pyapns2

  require 'pyapns2/version'

  class Error < StandardError; end

  attr_reader :host, :port

  class ProvisionedClient

    attr_reader :client, :app_id

    def initialize(client, app_id)
      @client = client
      @app_id = app_id
    end

    # See Pyapns2::Client#notify, with the exception this version prefills in the app_id.
    def notify(token, notification = nil)
      client.notify app_id, token, notification
    end

    # See Pyapns2::Client#feedback, with the exception this version prefills in the app_id.
    def feedback
      client.feedback app_id
    end

    def inspect
      "#<#{self.class.name} server=#{host}:#{port}, app_id=#{app_id}>"
    end

  end

  # Returns a pre-provisioned client that also automatically prepends
  # the app_id automatically to all api calls, making giving a simpler interface.
  def self.provision(options = {})
    host, port = options.delete(:host), options.delete(:port)
    host ||= "localhost"
    port ||= 7077
    client = new(host, port)
    client.provision(options)
    ProvisionedClient.new client, options[:app_id]
  end

  def initialize(host = 'localhost', port = 7077)
    raise ArgumentError, "host must be a string" unless host.is_a?(String)
    raise ArgumentError, "port must be a number" unless port.is_a?(Numeric)
    @host   = host
    @port   = port
    @http   = Net::HTTP.new host, port
    @xmlrpc = XML::XMLRPC::Client.new @http, "/"
  end

  def inspect
    "#<#{self.class.name} server=#{host}:#{port}>"
  end

  # Given a hash of options, calls provision on the pyapns server. This
  # expects the following options and will raise an ArgumentError if they're
  # not given:
  #
  # :app_id - A String name for your application
  # :timeout - A number (e.g. 15) for how long to time out after when connecting to the apn server
  # :env / :environment - One of production or sandbox. The type of server to connect to.
  # :cert - Either a path to the certificate file or the certificate contents as a string.
  def provision(options)
    options[:environment] = options.delete(:env) if options.has_key?(:env)
    app_id  = options[:app_id]
    timeout = options[:timeout]
    cert    = options[:cert]
    env     = options[:environment]
    raise ArgumentError, ":app_id must be a string" unless app_id.is_a?(String)
    raise ArgumentError, ":cert must be a string" unless cert.is_a?(String)
    raise ArgumentError, ":environment (or :env) must be one of sandbox or production" unless %w(production sandbox).include?(env)
    raise ArgumentError, ":timeout must be a valid integer" unless timeout.is_a?(Numeric) && timeout >= 0
    @xmlrpc.call 'provision', app_id, cert, env, timeout
    true
  rescue LibXML::XML::XMLRPC::RemoteCallError => e
    raise Error.new e.message
  end

  # The main notification endpoint. Takes the app_id as the first argument, and then one
  # of three sets of notification data:
  #
  # 1. A single token (as a string) and notification (as a dictionary)
  # 2. A hash of token to notifications.
  # 3. An array of tokens mapping to an array of notifications.
  #
  # Under the hook, it will automatically convert it to the most appropriate form before continuing.
  # Will raise ArgumentError if you attempt to pass in bad information.
  def notify(app_id, token, notification = nil)
    if token.is_a?(Hash)
      token, notification = extra_notification_info_from_hash token
    end
    raise ArgumentError, "Please ensure you provide an app_id" unless app_id
    raise ArgumentError, "Please ensure you provide a single notification or an array of notifications" unless typed_item_of(notification, Hash)
    raise ArgumentError, "Please ensure you provide device tokens or a string of tokens" unless typed_item_of(token, String)
    types = [notification.is_a?(Array), token.is_a?(Array)]
    if types.any? && !types.all?
      raise ArgumentError, "The notifications and the strings must both  be arrays if one is."
    end
    @xmlrpc.call 'notify', app_id, token, notification
    true
  rescue LibXML::XML::XMLRPC::RemoteCallError => e
    raise Error.new e.message
  end

  # Takes an app id and returns the list of feedback from pyapns.
  def feedback(app_id)
    @xmlrpc.call('feedback', app_id).params
  rescue LibXML::XML::XMLRPC::RemoteCallError => e
    raise Error.new e.message
  end

  private

  def extra_notification_info_from_hash(hash)
    tokens, notifications = [], []
    hash.each_pair do |k,v|
      tokens        << k
      notifications << v
    end
    return tokens, notifications
  end

  def typed_item_of(value, klass)
    value.is_a?(klass) || (value.is_a?(Array) && value.all? { |v| v.is_a?(klass) })
  end

end
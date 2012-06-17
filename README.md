# Pyapns2

Pyapns2 is a Ruby client for the [pyapns](https://github.com/samuraisam/pyapns) push notification
server written in Ruby. It provides a simple interface to implement the process of sending push
notifications and receiving feedback, with pyapns taking care of all of the hard work.

It's built to be simple - I built the client around [libxml-xmlrpc](https://rubygems.org/gems/libxml-xmlrpc)
as an alternative to the built in Ruby library (with the intention of using something that behaved better under Ruby
1.9 with pyapns).

## Installing

Adding pyapns2 to your application is as simple as adding the following to your gemfile:

gem 'pyapns2', '~> 1.0'

## Using

Pyapns2 is designed to be as simple as possible to use - Our entire api is appx. four primary methods, with a fifth
added to simplify the whole process. As an example, you could do:

```ruby
client = Pyapns2.new 'notifications.example.com', 7077 # Defaults to localhost:7077

client.provision({
  app_id:  "your-application-id", # An internal app - used for notify and feedback.
  timeout: 15, # How long to timeout attempting to connect?
  cert:    "your-cert-contents-here", # A path to a certificate or the local certificate itself.
  env:     "sandbox" # Or production, also accessible as :environment
})

# Notifications use the previous app id + a token + a hash
client.notify 'your-application-id', 'device-token', {aps: {alert: "Text"}}
# Or, sending many at once
client.notify 'your-application-id', ['device-token1', 'device-token2'], [{aps: {alert: "Text"}}, {aps {alert: "Notification 2"}}]
# Or, alternatively,
client.notify 'your-application-id', "device-token-1" => {aps: {alert: "Text"}}, "device-token-2" => {aps {alert: "Notification 2"}}]

# Finally, to get feedback:
p client.feedback 'your-application-id'
```

Note that to use a client, you need to ensure you call provision at least once for the app id - An error
will be raised otherwise.

Finally, it offers a shorthand - using `Pyapns2.provisioned` you can return a pre-provisioned client that
automatically prepends the app id, e.g:

```ruby
client = Pyapns2.provisioned({
  host:    "your-pyapns-host.example.com" ,
  port:    7077,
  app_id:  "your-application-id",
  timeout: 15,
  cert:    "your-cert-contents-here",
  env:     "sandbox"
})

client.notify 'device-token', {aps: {alert: "Text"}}
p client.feedback
```

## Running the Tests

Running the tests is the hardest part of this project, due to the manner in which it operates.
To make it easier, the test suite uses VCR to make it easy to run against a live server.

To do so, you need to first set several environment variables:

* `PYAPNS_HOST` - Defaults to localhost, change if using another host.
* `PYAPNS_PORT` - Defaults to 7077, change if using another port.
* `PYAPNS_CERT` - The name (e.g. `fake` is the default for `spec/certificates/fake.pem`) for the certificate to us.
* `TEST_PUSH_TOKEN` - A sandbox token for the cert specified.

Note that you'll want to remove the cassette first before running the tests on new additions, as the provisioning
portion must be run to match the fake app id.

E.G, I use: `rm -rf spec/cassettes/*.yml && bundle exec rake` to run the test suite from scratch.

## Contributors

- [Darcy Laycock](https://github.com/Sutto) - Main developer, current maintainer.

## Contributing

We encourage all community contributions. Keeping this in mind, please follow these general guidelines when contributing:

* Fork the project
* Create a topic branch for what you’re working on (git checkout -b awesome_feature)
* Commit away, push that up (git push your\_remote awesome\_feature)
* Create a new GitHub Issue with the commit, asking for review. Alternatively, send a pull request with details of what you added.
* Once it’s accepted, if you want access to the core repository feel free to ask! Otherwise, you can continue to hack away in your own fork.

Other than that, our guidelines very closely match the GemCutter guidelines [here](http://wiki.github.com/qrush/gemcutter/contribution-guidelines).

(Thanks to [GemCutter](http://wiki.github.com/qrush/gemcutter/) for the contribution guide)

## License

Pyapns2 is released under the MIT License (see the [license file](https://github.com/filtersquad/rocket_pants/blob/master/LICENSE)) and is copyright Filter Squad, 2012.
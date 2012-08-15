UniData ORM [![Build Status](https://secure.travis-ci.org/jisraelsen/unidata.png?branch=master)](http://travis-ci.org/jisraelsen/unidata) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jisraelsen/unidata)
===========

A simple ORM for Rocket's UniData database.

Installation
------------

Add this line to your application's Gemfile:

    gem 'unidata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unidata

Usage
-----

### Connecting to Unidata:

```ruby
Unidata.prepare_connection(
  :user     => "admin",
  :password => "secret",
  :host     => "localhost",
  :data_dir => "/usr/uv/db"
)

Unidata.open_connection do
  # interact with Unidata here
end
```

Or, you can manually open and close the connection yourself.

```ruby
Unidata.open_connection

# interact with Unidata here

Unidata.close_connection
```

### Defining models:

```ruby
class Product < Unidata::Model
  self.filename = 'PRODUCT'

  field 1, :name,         String
  field 2, :description   # type is optional (defaults to String)
  field 3, :cost,         Float
  field 4, :available_on, Date
end
```

### Creating records:

```ruby
thingamajig = Product.new(
  :id         => 12345,
  :name       =>'Thingamajig',
  :cost       => 125.99,
  :available  => Date.today
)
thingamajig.save

whatsit = Product.new
whatsit.id = 12346
whatsit.name = 'Whatsit'
whatsit.cost = 999.99 
whatsit.available = Date.today
whatsit.save
```

### Retrieving records:

```ruby
product = Product.find(12345)
```

Or, you can just check if a record exists:

```ruby
Product.exists?(12345)
```

Contributing
------------

Pull requests are welcome.  Just make sure to include tests!

To run tests, install some dependencies:

```bash
bundle install
```

Then, run tests with:

```bash
rake spec
```

Or, If you want to check coverage:

```bash
COVERAGE=on rake spec
```

Issues
------

Please use GitHub's [issue tracker](http://github.com/jisraelsen/unidata/issues).

Author
------

[Jeremy Israelsen](http://github.com/jisraelsen)
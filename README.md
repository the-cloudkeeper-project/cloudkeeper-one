# cloudkeeper-one
OpenNebula backend for [cloudkeeper](https://github.com/the-cloudkeeper-project/cloudkeeper)

[![Build Status](https://secure.travis-ci.org/the-cloudkeeper-project/cloudkeeper-one.png)](http://travis-ci.org/the-cloudkeeper-project/cloudkeeper-one)
[![Dependency Status](https://gemnasium.com/the-cloudkeeper-project/cloudkeeper-one.png)](https://gemnasium.com/the-cloudkeeper-project/cloudkeeper-one)
[![Gem Version](https://fury-badge.herokuapp.com/rb/cloudkeeper-one.png)](https://badge.fury.io/rb/cloudkeeper-one)
[![Code Climate](https://codeclimate.com/github/the-cloudkeeper-project/cloudkeeper-one.png)](https://codeclimate.com/github/the-cloudkeeper-project/cloudkeeper-one)

##Requirements
* Ruby >= 2.0.0
* Rubygems

## Installation

###From RubyGems.org
To install the most recent stable version
```bash
gem install cloudkeeper-one
```

###From source (dev)
**Installation from source should never be your first choice! Especially, if you are not
familiar with RVM, Bundler, Rake and other dev tools for Ruby!**

**However, if you wish to contribute to our project, this is the right way to start.**

To build and install the bleeding edge version from master

```bash
git clone git://github.com/the-cloudkeeper-project/cloudkeeper-one.git
cd cloudkeeper-one
gem install bundler
bundle install
bundle exec rake spec
```

##Configuration
###Create a configuration file for cloudkeeper-one
Configuration file can be read by cloudkeeper-one from these
three locations:

* `~/.cloudkeeper-one/cloudkeeper-one.yml`
* `/etc/cloudkeeper-one/cloudkeeper-one.yml`
* `PATH_TO_GEM_DIR/config/cloudkeeper-one.yml`

The default configuration file can be found at the last location
`PATH_TO_GEM_DIR/config/cloudkeeper-one.yml`.

## Usage

TODO

## Contributing
1. Fork it ( https://github.com/the-cloudkeeper-project/cloudkeeper-one/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

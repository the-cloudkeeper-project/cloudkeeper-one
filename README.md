<h1 align="center">
  <img src="https://i.imgur.com/95iUPzX.png" alt="Logo Cloudkeeper-ONE" title="Logo Cloudkeeper-ONE" width="256"/>
  <p>Cloudkeeper-ONE</p>
</h1>

<p align="center">
  <a href="http://travis-ci.org/the-cloudkeeper-project/cloudkeeper-one"><img src="https://img.shields.io/travis/the-cloudkeeper-project/cloudkeeper-one.svg?style=flat-square" alt="Travis"></a>
  <a href="https://depfu.com/repos/the-cloudkeeper-project/cloudkeeper-one"><img src="https://img.shields.io/depfu/the-cloudkeeper-project/cloudkeeper-one.svg?style=flat-square" alt="Depfu"></a>
  <a href="https://rubygems.org/gems/cloudkeeper-one"><img src="https://img.shields.io/gem/v/cloudkeeper-one.svg?style=flat-square" alt="Gem"></a>
  <a href="https://codeclimate.com/github/the-cloudkeeper-project/cloudkeeper-one"><img src="https://img.shields.io/codeclimate/maintainability/the-cloudkeeper-project/cloudkeeper-one.svg?style=flat-square" alt="Code Climate"></a>
  <a href="https://hub.docker.com/r/cloudkeeper/cloudkeeper-one/"><img src="https://img.shields.io/badge/docker-ready-blue.svg?style=flat-square" alt="DockerHub"></a>
  <a href="https://zenodo.org/record/1134571"><img src="https://img.shields.io/badge/dynamic/json.svg?label=DOI&colorB=0D7EBE&prefix=&suffix=&query=$.doi&uri=https%3A%2F%2Fzenodo.org%2Fapi%2Frecords%2F1134571&style=flat-square" alt="DOI"></a>
</p>

<h4 align="center">OpenNebula backend for <a href="https://github.com/the-cloudkeeper-project/cloudkeeper">Cloudkeeper</a></h4>

## What does Cloudkeeper-ONE do?
Cloudkeeper-ONE is able to manage [OpenNebula](https://opennebula.org/) CMF - upload, update and remove images and templates representing EGI AppDB appliances. Cloudkeeper-ONE runs as a server listening for [gRPC](http://www.grpc.io/) communication usually from core [cloudkeeper](https://github.com/the-cloudkeeper-project/cloudkeeper) component.

## Requirements
* Ruby >= 2.2.0
* Rubygems
* OpenNebula >= 5.2 (doesn't have to be present on the same machine)

## Installation

### From RubyGems.org
To install the most recent stable version
```bash
gem install cloudkeeper-one
```

### From source (dev)
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

## Configuration
### Create a configuration file for Cloudkeeper-ONE
Configuration file can be read by Cloudkeeper-ONE from these
three locations:

* `~/.cloudkeeper-one/cloudkeeper-one.yml`
* `/etc/cloudkeeper-one/cloudkeeper-one.yml`
* `PATH_TO_GEM_DIR/config/cloudkeeper-one.yml`

The default configuration file can be found at the last location
`PATH_TO_GEM_DIR/config/cloudkeeper-one.yml`.

## Usage
Cloudkeeper-ONE is run with executable `cloudkeeper-one`. For further assistance run `cloudkeeper-one help sync`:
```bash
Usage:
  cloudkeeper-one sync --appliances-permissions=APPLIANCES-PERMISSIONS --appliances-tmp-dir=APPLIANCES-TMP-DIR --identifier=IDENTIFIER --listen-address=LISTEN-ADDRESS --opennebula-api-call-timeout=OPENNEBULA-API-CALL-TIMEOUT --opennebula-datastore=OPENNEBULA-DATASTORE

Options:
  --listen-address=LISTEN-ADDRESS                                            # IP address gRPC server will listen on
                                                                             # Default: 127.0.0.1:50051
  [--authentication], [--no-authentication]                                  # Client <-> server authentication
  [--certificate=CERTIFICATE]                                                # Backend's host certificate
                                                                             # Default: /etc/grid-security/hostcert.pem
  [--key=KEY]                                                                # Backend's host key
                                                                             # Default: /etc/grid-security/hostkey.pem
  --identifier=IDENTIFIER                                                    # Instance identifier
                                                                             # Default: cloudkeeper-one
  [--core-certificate=CORE-CERTIFICATE]                                      # Core's certificate
                                                                             # Default: /etc/grid-security/corecert.pem
  --appliances-tmp-dir=APPLIANCES-TMP-DIR                                    # Directory where to temporarily store appliances
                                                                             # Default: /var/spool/cloudkeeper/appliances
  [--appliances-template-dir=APPLIANCES-TEMPLATE-DIR]                        # If set, templates within this directory are used to construct images and templates in OpenNebula
  --appliances-permissions=APPLIANCES-PERMISSIONS                            # UNIX-like permissions appliances will have within OpenNebula
                                                                             # Default: 640
  [--opennebula-secret=OPENNEBULA-SECRET]                                    # OpenNebula authentication secret
                                                                             # Default: oneadmin:opennebula
  [--opennebula-endpoint=OPENNEBULA-ENDPOINT]                                # OpenNebula XML-RPC endpoint
                                                                             # Default: http://localhost:2633/RPC2
  --opennebula-datastore=OPENNEBULA-DATASTORE                                # OpenNebula datastore images will be uploaded to
                                                                             # Default: default
  --opennebula-api-call-timeout=OPENNEBULA-API-CALL-TIMEOUT                  # How long will cloudkeeper-one wait for image/template operations to finish in OpenNebula
                                                                             # Default: 3h
  [--opennebula-allow-remote-source], [--no-opennebula-allow-remote-source]  # Allows OpenNebula to directly download remote image
                                                                             # Default: true
  --logging-level=LOGGING-LEVEL
                                                                             # Default: ERROR
                                                                             # Possible values: DEBUG, INFO, WARN, ERROR, FATAL, UNKNOWN
  [--logging-file=LOGGING-FILE]                                              # File to write logs to
                                                                             # Default: /var/log/cloudkeeper/cloudkeeper-one.log
  [--debug], [--no-debug]                                                    # Runs cloudkeeper in debug mode
```

## Contributing
1. Fork it ( https://github.com/the-cloudkeeper-project/cloudkeeper-one/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

##Acknowledgements
This work is co-funded by the [EOSC-hub project](http://eosc-hub.eu/) (Horizon 2020) under Grant number 777536.
<img src="https://wiki.eosc-hub.eu/download/attachments/1867786/eu%20logo.jpeg?version=1&modificationDate=1459256840098&api=v2" height="24">
<img src="https://wiki.eosc-hub.eu/download/attachments/18973612/eosc-hub-web.png?version=1&modificationDate=1516099993132&api=v2" height="24">

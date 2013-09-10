unless defined? BASE_DIR
  BASE_DIR = File.expand_path('../..', __FILE__)
end
unless defined? LEAP_CA_CONFIG
  LEAP_CA_CONFIG = '/etc/leap/tapicero.yaml'
end

#
# Load Config
# this must come first, because CouchRest needs the connection defined before the models are defined.
#
require 'tapicero/config'
Tapicero::Config.load(BASE_DIR, 'config/default.yaml', LEAP_CA_CONFIG, ARGV.grep(/\.ya?ml$/).first)

#
# Load Tapicero
#
require 'tapicero/json_stream'
require 'tapicero/couch_stream'
require 'tapicero/couch_changes'

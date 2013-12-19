unless defined? BASE_DIR
  BASE_DIR = File.expand_path('../..', __FILE__)
end
unless defined? TAPICERO_CONFIG
  TAPICERO_CONFIG = '/etc/leap/tapicero.yaml'
end

module Tapicero
  class <<self
    attr_accessor :logger
    attr_accessor :config
  end


  #
  # Load Config
  # this must come first, because CouchRest needs the connection
  # defined before the models are defined.
  #
  require 'couchrest/changes'
  configs = ['config/default.yaml', TAPICERO_CONFIG, ARGV.grep(/\.ya?ml$/).first]
  self.config = CouchRest::Changes::Config.load(BASE_DIR, *configs)
  self.logger = CouchRest::Changes::Config.logger

  #
  # Load Tapicero Parts
  #
  require 'tapicero/user_database'

  def self.user_database(id)
    UserDatabase.new(config.couch_host, config.options[:db_prefix] + id)
  end
end

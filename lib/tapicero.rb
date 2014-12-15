unless defined? BASE_DIR
  BASE_DIR = Pathname.new(__FILE__) + '../..'
end

module Tapicero
  class <<self
    attr_accessor :logger
    attr_accessor :config
  end

  # reraise exceptions instead of retrying
  # used in tests
  unless defined? RERAISE
    RERAISE = false
  end
  #
  # Load Config
  # this must come first, because CouchRest needs the connection
  # defined before the models are defined.
  #
  require 'couchrest/changes'
  self.config = CouchRest::Changes::Config.load(BASE_DIR, *CONFIGS)
  self.logger = CouchRest::Changes::Config.logger

  # hand flags over to CouchRest::Changes
  if defined? FLAGS
    config.flags = FLAGS
  end

end
